---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - rig
  - animate
  - try
---

앞서 오브젝트들을 그리는 방법에 대해서 알아보았다.([hnalding vertices]({{ site.baseurl }}{% post_url 2017-05-14-handling-vertices-and-indices-in-unity %}), [handling uvs]({{ site.baseurl }}{% post_url 2017-05-15-handling-uv-and-material-in-unity %})) 폴리곤을 그리고 색을 칠하는 방법이었다. 하지만 이런 기능만 가지고 게임을 만들기에는 약간 부족하다. 보통 게임을 만들때 케릭터들의 부드러운 움직임을 표현해야 한다. 2D 게임은 보통 그림을 여러장을 그려서 움직이게 보이게 한다. 하지만 3D 게임에서의 부드러운 움직임은 2D 게임의 표현과는 다르게 표현한다. 일단 부드럽게 움직여야할 단위가 다르다. 메쉬의 정점들을 부드럽게 움직여야하기 때문에 2D 게임의 움직임과는 다른 무언가가 필요하다.

2D 게임에서 그림을 한꺼번에 움직이는 것처럼 단순하게 메쉬 전체를 부드럽게 움직여서 해결되면 좋겠지만 이 방법은 조금 문제가 있다. 관절같은 접합 부분에서 부드럽게 처리해야 하는 부분 즉 어떤 정점만 부드럽게 움직여야하는 문제가 있다. 그래서 고안된 방법은 특정한 위치를 설정해서 그 위치를 기준으로 정점들을 움직여주는 방법이다.

언급한 특정한 위치를 _Bone_ : 뼈라고 한다. 뼈를 움직여서 정점들을 직접 움직이는 것이다. 그리고 뼈를 기준으로 움직이는 것을 _Skinning_ 이라고 한다. 사람의 뼈가 움직이면 피부도 따라서 움직이듯이 피부를 직접 설정하는 것을 _Skinning_ 이라고 하는 것이다. 그리고 _Bone_ 의 위치도 상당히 중요하다. 자연스러운 움직임을 만들려면 만들어진 메쉬에 잘 맞게 위치를 설정해주어야 하기 때문이다. 위치 뿐만아니라 여러 움직이는 범위나 뼈의 계층 구조를 잘 설정해주어야 자연스러운 움직임을 나타낼 수 있다. 이러한 작업을 _Rigging_ 이라 한다. 보통 3D 오브젝트를 만들고 _Rigging_ 과 _Skinning_ 을 하는 작업은 그래픽 아티스트가 직접 해주지만 우리는 이 과정을 이해해야 하기에 Unity 에서 직접 만들어 볼 것이다.

## Unity 에서 직접 리깅, 스키닝하기

<!--
리깅 설명하기 : 메쉬에 정점이 움직이는 방법을 기술해야함.
그 기준은 Unity Transform 으로 정해주어야 함.
또한 값을 넣어줄때마다 변환 행렬이 필요함. mesh.bindposes 임. bone 마다 매칭해서 넣어주어야함.

Mesh.bones
Mesh.bindposes
-->

## MeshRenderer vs SkinnedMeshRenderer

이전 게시물들에서는 Unity 에서 __Mesh__ 를 그릴때 사용하는 컴포넌트가 __MeshRenderer__ 였었다. 하지만 이번 게시물에서는 단어가 하나가 더 추가된 __SkinnedMeshRenderer__ 를 사용했다.

__MeshRenderer__ 는 정점들이 움직이지 않는다는 전제를 두고 그려주는 컴포넌트다. 그래서 정점의 움직임 자체를 지원하지 않는다. 물론 GameObject 자체의 위치를 바꾸어 주면되지만 __Mesh__ 에 직접 접근하지 않는게 목적이다. 기능이 없다고해서 꼭 나쁜것은 아니다. 정점 데이터가 변경되지 않는다는 전제하에 렌더링이 이루어지기 때문에 Unity 에서 가능한한 최적화를 해준다.

__SkinnedMeshRenderer__ 는 모든것이 집약된 컴포넌트로 모든 데이터를 전부다 __SkinnedMeshRenderer__ 컴포넌트에 넣어주어야 한다. __Mesh__, __Material__ 등 데이터를 전부 넣어주어야 하고 _Bone_ 을 설정하려면 _Bone_ 에 해당하는 __Transform__ 도 직접 넣어주어야 한다. 그나마 다행인 것은 Unity 에서 __SkinnedMeshRenderer__ 에 대한 최적화를 몇개 지원한다. 그 중에서도 가장 주의깊게 봐야할 것이 하나 있다. Build Setting -> Player Setting 으로 들어가면 Inspector 에 아래 그림과 같이 나오게 될 것이다.

![PlayerSetting - Rendering](/images/playersetting_rendering.png)

여기 메뉴에서 주목할 부분은 바로 _GPU Skinning_ 이다. 보통 메쉬의 정보들은 GPU 가 가지고 있는 메모리에 들어가게 된다. 그리고 GPU 는 자기가 가지고 있는 메모리를 참조해서 렌더링을 한다. _GPU Skinning_ 기능을 안킨 상태에서는 정점을 움직일때마다 GPU 의 메모리에 복사작업을 계속해야하는데, _GPU Skinning_ 을 키게 되면 GPU 안에서 직접 움직이게 되므로 GPU 의 성능이 꽤나 준수하다면 성능 향상을 기대할 수 있다. 저사양의 모바일 기기를 타겟으로 한다면 벤치마킹을 직접 해보는 것을 추천한다. 또한 _GPU Skinning_ 은 Graphics API 의 버젼이 조금 높아야 지원한다. DX11, OpenGL ES 3.0 그리고 XBox360 이상에서만 지원한다고 한다. 기능을 사용할 떼는 타겟 디바이스를 유의깊게 살펴보길 바란다.

<!--
그냥 움직이기
일반 lerp 를 이용한 animating
AnimationCurve 를 활용한 animating
AnimationClip 을 활용한 animating
-->

# 참조

- [Wikipedia : Skinning](https://en.wikipedia.org/wiki/Skinning)
- [Wikipedia : Skeletal animation](https://en.wikipedia.org/wiki/Skeletal_animation)
- [코드로 리깅하고 애니메이션 하기](https://github.com/GameEngineStudy/CodeRigging)
- [Unity ref: PlayerSettings.gpuSkinning](https://docs.unity3d.com/ScriptReference/PlayerSettings-gpuSkinning.html)
