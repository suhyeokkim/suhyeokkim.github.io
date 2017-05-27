---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - rendering
  - cg
  - try
---

이전에 쓴 글([handling uvs and material]({{ site.baseurl }}{% post_url 2017-05-15-handling-uv-and-material-in-unity %}))에서 쉐이더에 대한 언급을 한적이 있다. 간단하게 전체적인 의미와 역할에 대해서 설명했었다. 이 글에서는 조금 더 자세하게 알아보고 CG 를 이용해서 직접 다루는 방법에 대해서 알아보겠다.

3D 오브젝트는 GPU 에서 특정한 연산을 하여 화면상에 실제로 그려진다. 예전에는 그리는 방식이 정해져 있어 그 방식에 맞추어 데이터를 넣어주면 GPU 와 Graphics API 가 알아서 3D 오브젝트를 그렸었다. 하지만 기술은 점점 발전하여 프로그래머들이 직접 많은것을 제어할 수 있게 되었고 현재는 꽤 많은 것들이 가능하게 되었다. 그 발전속에서 나타난 것이 쉐이더다. 쉐이더는 3D 오브젝트를 그리는 방식을 적어놓은 코드라고 할 수 있다.

3D 오브젝트를 그리는 쉐이더 코드는 두가지로 나뉘는데, 하나는 vertex 를 처리하는 과정 또 하나는 pixel 자체를 처리하는 코드로 나뉜다. 이 두가지 과정을 잘 처리하면 게임에서 원하는 연출과 성능 두가지 토끼를 잡을 수 있다. 물론 잘하기 힘들다. 그래서 두 방법에서 프로그래머가 직접 코드를 짜서 넣으면서 게임의 그래픽을 원하는대로 커스터마이징이 가능하게 되었다. 이로써 꽤 많은 것을 실현 가능하게 되었었다. 하지만 이게 다가 아니였다.

쉐이더를 사용한 AAA급 3D 게임들과 함께 GPU 도 격렬하게 발전했다. 발전한 만큼 GPU 의 퍼포먼스는 점점 괴물이 되어가고 그 과정에서 vertex shader 와 pixel shader 를 단순하게 그리는 것에만 사용하는 것이 아니라 다른 계산이 필요한 곳에 써먹기 시작했고 편법을 사용한 많은 기술이 나왔었다. ([vtf](http://www.gamedevforever.com/61)) 그렇게 프로그래머의 니즈를 파악한 GPU 제조사는 다른 기술을 개발한다. 이름하여 GPGPU 라는 이름의 기술인데 풀어 쓰면 _"general purpose computing on graphics processing units"_ 이다. _GPU 상의 범용 계산_ 이라는 뜻이다. 즉 위에서 언급한 병렬 계산이 가능한 것들을 편법을 쓰지말고 직접 이 기술을 사용해서 사용하라는 것이다. 이 GPGPU 기술이 나오면서 GPU 의 하드웨어적인 퍼포먼스에 따라 엄청 많은 것들을 가능하게 되었다. GPGPU 를 통해 불편했던 편법을 사용하던 기법들이 변형되어 쏟아져 나왔으며 새로운 기술 또한 엄청나게 쏟아져 나왔다. 그리고 그 기술들은 일반적으로 알려진 3D 그래픽이 차용된 AAA 급 게임들에 사용되어 일반 사용자들은 엄청난 그래픽을 자랑하는 게임들을 경험할 수 있게 되었다. 또한 최근에 _AI_ 기술이 대두되면서 GPGPU 가 더욱더 각광받게 되었다.

이렇게 우리에게 다가오는 것은 꽤 많은 게임들의 발전인데, 다만 우리가 이 게임들의 기술에 접근하려면 꽤 많은 지식과 발상의 전환이 필요하다. 쉐이더만 하더라도 쉐이더 코드는 컴파일되어 GPU 에서 실행된다. CPU 에서 실행되는 일반적인 코드와 조금 다른 점은 CPU 에서 처리되는 것은 멀티스레딩을 하지 않는 이상 상당히 선형적인 코드를 짜게 되고 GPU 에서 돌아가는 쉐이더 코드를 짤 때는 병렬(parallel) 환경에서 돌아가게 짜야한다. 쉐이더 코드를 짤 때 첫번째로 겪게되는 어려움은 이것이다. 쉐이더까지 건드리게되면 경험이 어느정도 있는 상태일텐데, 개념을 조금 깨부수고 아예 병렬적으로 코드를 짜야하니 적응하는 것에 시간이 꽤나 소모된다.

우선 Unity 에서 가능한 것들이 꽤 있으니 입문용으로 몇가지 시도해보자.

<!-- more -->

Unity 는 여러 메인 스트림의 쉐이더 언어를 통해 쉐이더 코딩이 가능하다. 각각 언어마다 큰 차이는 없다. DirectX 와 OpenGL 에서 각각 지원하는 HLSL, GLSL 은 C 기반의 언어이고, Unity 에서 가장 많이 쓰이는 CG 는 NVidia 에서 MS 와 협력하여 만들어졌기 때문에 HLSL 과 비슷할 수 밖에 없다.([Cg & HLSL FAQ](https://web.archive.org/web/20120824051248/http://www.fusionindustries.com/default.asp?page=cg-hlsl-faq)) 또한 쓰이는 문법도 많은 편은 아니라 한가지를 익혀두면 나머지를 사용하는데 크게 불편함은 없을 것이다. 물론 Unity 에서 쓰이는 쉐이더는 ShaderLab 을 기반으로 코딩해야 하기 때문에 네이티브 CG, HLSL, GLSL 과 전체적인 개괄은 다르다. 더 궁금한 사람은 Unity 본사 엔지니어 Aras 가 답변한 [질문 링크](https://forum.unity3d.com/threads/hlsl-cg-shaderlab.4300/) 를 보면 된다.

<!--
  쉐이더는 뭐시당가?
  vertex shader, fragment shader(pixel shader)
  GPGPU -> computeshader

  shaderlab? cg? hlsl?

  CG, hlsl, glsl
  CG 를 이용해서 쉐이더 직접 만져보기
   - 표면 쉐이더 : 기본 버텍스 라이팅(diffuse vs specular)
   - 버텍스 쉐이더 & 픽셀 쉐이더 : 색, 텍스쳐, 블러

  번외 : OnRenderTexture, rendertexture
-->

## 참조

 - [Fixed function pipeline](https://www.khronos.org/opengl/wiki/Fixed_Function_Pipeline)
 - [Unity ref : shader references](https://docs.unity3d.com/kr/current/Manual/SL-Reference.html)
 - [Unity forum : hlsl? cg? shaderlab?](https://forum.unity3d.com/threads/hlsl-cg-shaderlab.4300/)
 - [Unity forum : CG Toolkit is legacy](https://forum.unity3d.com/threads/cg-toolkit-legacy.238181/)
 - [NVidia developer : CG Toolkit](https://developer.nvidia.com/cg-toolkit)
