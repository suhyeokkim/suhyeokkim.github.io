---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
---

real-time rendering 을 구현할 때, _drawcall_  을 적게 유지하는 것은 굉장히 중요하다. 특히나 게임 같은 렌더링 외 다른 처리도 중요해지는 경우, CPU 부담이 최소한이 되어야 더 많은 것들을 할 여유 비용이 생겨 굉장히 중요하다. _drawcall_ 을 줄이는 관점에서 Unity 를 사용할 때, 지원하는 기능들이 여러개 있어 혼동이 올 수도 있다. 최근에는 각자의 정의와 상관관계를 명확히 하지 않아서 이를 정리하는데에 약간의 시간을 투자했었다.

_static/dynamic batching_, _gpu instancing_ 의 예상되는 동작과 상관관계를 알아본다,

<!-- more -->

# Unity 에서의 렌더링 데이터

Unity 에서 일반적으로 3차원 기하 물체를 렌더링하기 위해선 아래와 같은 데이터가 필요하다.

1. 메시
2. 메터리얼

두가지는 _MeshRenderer_ or _SkinnedMeshRenderer_ 에 쌍으로 들어갈 시 유효하게 렌더링 할 수 있다. 그리고 이 두가지 안에서 또 여러가지 것들이 있다.

1. 메시
   1. 정점 별 데이터 : 위치, uv 좌표(보통 2차원), tangent frame 데이터, bone indices/weight, color, ...
   2. 스켈레톤 별 데이터 (스키닝 메시 전용) : bindposes
   3. 정점 인덱스 데이터 (보통 uint16 을 사용)
2. 메터리얼
   1. shader (shader varaints 집합)
   2. shader varaints 를 결정하는 키워드
   3. 각 개체 별 세팅 값 (texture/cubemap reference, float, ...)

일반적으론 이렇게 구성된다. 아래 소개할 방법들은 이 두가지 중 하나를 합치는 방법들이다.

# _static/dynamic batching_

_static batching_, _dynamic batching_ 두 기능은 꽤 오래된 최적화 방법이다. [Draw call batching](https://docs.unity3d.com/2019.4/Documentation/Manual/DrawCallBatching.html) 문서에서 존재하는 지원 버젼을 보면 5.2 부터 있다. 이로 부터 유추할 수 있는 건, 모바일이 강세이던 시장에서 지금은 레거시로 취급되는 graphics api 에서도 돌아가는 방법이라는 것이다. 어떤 방법이길래 그게 가능한 것일까?

두 방법은 _batching_ 이라는 공통된 단어를 사용한다. 보통은 일괄 처리를 의미하지만 여기서 말하는 _batching_ 은, 같은 __메터리얼__ 을 사용하는 __메시__ 들을 묶어서 한꺼번에 drawcall 을 전송하는 것이다. _static batching_, _dynamic batching_ 의 기본적인 방법론은 이를 따른다. 두 방법의 차이는 _batching static_ 의 여부에 달려있다.

_static batching_ 은 _batching static_ 이 true 로 설정된 경우를 처리한다. 이의 방법도 두가지가 있는데, 메시를 합치는 타이밍이 빌드냐 런타임이냐의 차이가 있다. 빌드 타임에 처리하는 것은, PlayerSettings 의 _static batching_ 옵션을 키면 모든 _batching static_ 마킹 된걸 전부 처리한다. 에셋 번들로 빠져있다면, 에셋 번들 빌드 시에 처리한다. 런타임에 처리하기 위해선 _StaticBatchingUtility_ 를 사용하면 된다.

_dynamic batching_ 은 _batching static_ 이 false 로 설정된 경우를 처리한다. 런타임에 메시 합침 등 기타 처리를 한다. 사용자가 할 것은 메시의 크기를 일정 이하로 유지하는 것이다. 이는 메모리 사용량이 극단적으로 느는 것을 피하기 위함이 아닌가 싶다. 그리고 이전의 모바일에만 많이 사용되던 때는 아무래도 기하의 정밀도를 크게 낮추는 편이라서 묶기가 더 수월했을 듯 하다.

_static batching_ 의 비용은 마치 _static_ 하지만 완전히 그런 것은 아닌 것 같다. 같은 __메터리얼__ 을 사용하는 __메시__ 들을 묶을 때, 버텍스를 그대로 넣으면 _culling_ 과 상관없이 버텍스가 들어갈 수 있다는 우려가 있다. 다만 이는 _index buffer_ 를 내부적으로 업데이트 함으로써 큰 문제는 아니지만, ([링크](https://answers.unity.com/questions/593206/how-static-batching-works.html)) 결과적으로 런타임에 처리하는 비용이 존재한다. 그리고 합칠 수 있는 크기의 한계가 있다. 

> Batch limits are 64k vertices and 64k indices on most platforms (48k indices on OpenGLES, 32k indices on macOS).

# _gpu instancing_

_GPU Instancing_ 도 _xxx batching_ 처럼 오래된 건 아니지만 나온지 꽤나 오래되었다. [GPU Instancing](https://docs.unity3d.com/2019.4/Documentation/Manual/GPUInstancing.html) 의 지원 버젼을 보면 5.4 부터 업데이트 된걸 알 수 있다. 현재 존재하는 대부분의 모바일 디바이스는 _gles 3.0_ 을 지원하니 문제가 없다면 지금 사용하기에도 좋다.

이 방법은 _xxx batching_ 과는 반대로, 같은 __메시__ 를 사용하는 __메터리얼__ (전부는 아님) 을 묶어서 한꺼번에 drawcall 을 전송하는 것이다.

이의 사용 방법은 _gpu instancing_ 을 지원하는 쉐이더를 사용한다면 굉장히 간단하다. `material.enableInstancing = true` 를 설정해주면 끝이다. 하지만 쉐이더를 직접 작성해줘야 한다면 접근자 처리가 조금 필요하다. 이는 [GPU Instancing 매뉴얼](https://docs.unity3d.com/2019.4/Documentation/Manual/GPUInstancing.html)을 참고하면 된다.

_gpu instancing_ 의 비용은 매 프레임별로 각 인스턴스 별 데이터를 전송 해야 하고, 그 임시 버퍼 비용이 필요하다. 그리고 내부적으로 _Graphics.DrawMeshInstanced_ 를 사용해서 각 인스턴스 식별자를 넣어주고, _constant buffer_(gl 에선 _uniform buffer_)를 참조해서 사용한다. 

``` csharp
// UnityInstancing.cginc
// SV_InstanceID 를 사용하는 것을 알 수 있다.
#define DEFAULT_UNITY_VERTEX_INPUT_INSTANCE_ID uint instanceID : SV_InstanceID;
#define UNITY_GET_INSTANCE_ID(input)    input.instanceID
```

이러한 관점에서 버텍스별 메모리를 추가적으로 사용하고, _constant buffer_ 접근을 하기 때문에 버퍼가 너무 크다면 캐시 미스가 심하게 날 수 있다. 이 경우 쉐이더 코드를 변경해서 최대 인스턴싱 갯수를 설정 가능하다. 다만 최대 인스턴싱 갯수는 _constant buffer_ 의 메모리 한계에 부딫쳐 한계가 존재할 수 있다. 이는 _graphics driver api_ 에 접근해 가져와야 하기 때문에 명시적으로 쓰진 않는다.

그리고 메터리얼의 POD 는 합쳐주지만, _texture_ 는 합쳐주지 않는다. 아마도 용량이 커서 그런 듯 하다. 씬에 배치된 바뀌지 않는 렌더링 개체의 경우 직접 합쳐주는 것도 방법일 듯 하다.

# 우선순위

[GPU Instancing](https://docs.unity3d.com/2019.4/Documentation/Manual/GPUInstancing.html) 의 `Batching priority` 항목을 보면, _xxx batching_ 과 _gpu instancing_ 간의 상관관계를 알 수 있다.

> When batching, Unity prioritizes Static batching over instancing. If you mark one of your GameObjects for static batching, and Unity successfully batches it, Unity disables instancing on that GameObject, even if its Renderer uses an instancing Shader. When this happens, the Inspector window displays a warning message suggesting that you disable Static Batching. To do this, open the Player settings (Edit > Project Settings, then select the Player category), open Other Settings for your platform, and under the Rendering  section, disable the Static Batching setting.

> Unity prioritizes instancing over dynamic batching. If Unity can instance a Mesh, it disables dynamic batching for that Mesh.

단순히 이야기 하자면 `batching static == true` 일 떄 static batching 조건이 충족되면 gpu instancing 보다 먼저 적용하고, `batching static == false` 일 떄 gpu instacning 을 적용 가능하다면 dynamic batching 보다 먼저 적용한다는 뜻이다.

# 결론

단순하게 성능을 끌어 올리기에 _static batching_ 은 쉽게 처리가능한 방법이지만, 별도의 컬링 비용을 제거하기 위해선 빌드타임에 지역적으로 메시를 묶는게 좋을 듯 싶다. 이러면 메모리 비용도 아낄 수 있을 듯. _gpu instancing_ 은 꽤 쓸만하다. _constant buffer_ 기반이기 때문에 _xxx batching_ 보단 추가적인 메모리 비용이 덜해서 단순하게 하나만 적용하라면 _gpu instancing_ 을 적용하는게 나을 것 같다.

그렇지만 프로파일링 후 판단은 언제나 필수다. 같은 메시가 전혀 반복되지 않는다면 _xxx batching_ 도 고려해볼 법 하다.

_static/dynamic batching_, _gpu instancing_ 의 동작과 상관관계에 대해서 정리했다. 다음 글에선 shader model 4.5 ([Unity 가 정의한](https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html)) 이상에 지원하는 _SRP Batcher_, _DOTS Instancing_, _BatchRendererGroup_ 에 대해서 알아본다.

<!-- 
# DOTS Instancing & BatchRendererGroup (SRP batcher)

나온지 얼마 안됨.
현대적인 기기에서만 돌아감 (gles 3.1 이상)
메시를 합쳐서 drawcall 줄임

https://docs.unity3d.com/2022.1/Documentation/Manual/batch-renderer-group.html
https://docs.unity3d.com/2022.1/Documentation/Manual/dots-instancing-shaders.html
-->

# 참조

- [Unity Manual : Draw call batching](https://docs.unity3d.com/2019.4/Documentation/Manual/DrawCallBatching.html)
- [Unity Manual : GPU Instancing](https://docs.unity3d.com/2019.4/Documentation/Manual/GPUInstancing.html)
- [Unity Forum : How static batching works?](https://answers.unity.com/questions/593206/how-static-batching-works.html)

<!--
- https://docs.unity3d.com/Manual/SRPBatcher.html
- https://forum.unity.com/threads/srp-batcher-and-gpu-instancing.833362/
- https://docs.unity3d.com/2022.1/Documentation/Manual/batch-renderer-group.html
- https://docs.unity3d.com/2022.1/Documentation/Manual/dots-instancing-shaders.html
-->