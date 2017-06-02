---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - rendering
  - cg
  - try
---

[Simple shader programming]({{ site.baseurl }}{% post_url 2017-05-29-simple-shader-programming %}) 글 에서 간단하게 CG 를 통해 쉐이더를 작성하는 법에 대해서 알아보았다. 텍스쳐와 간단하게 색을 입히는 코드에 대해서 알아보았다. 하지만 이렇게 직접 쉐이더 코드를 변경하는 단계가 오게되면 이렇게 간단한 코드보다는 되게 복잡한 코드를 쓰는 경우가 많을 것이다. 또한 그 복잡한 코드들의 주요 원인은 보통 라이팅에 때문일것이다. 아무리 GPU 가 발전했다해도 빛에 대한 처리는 아직도 난감하다. 실제 빛의 속도는 _299792458m/s_ 이다. 대략 초당 3억 미터를 간다는 소리인데, 이를 컴퓨터에서 완벽하게 시뮬레이션을 하려면 답이 안나온다. 양자 컴퓨터가 나온다면 모르겠지만 말이다. 게다가 빛은 광자라는 미세한 입자로 나누어져 있고 이와 같이 상호작용하는 물체또한 입자단위로 빛을 반사하는데 모든 것을 똑같이 표현할 수는 없다.

그래서 컴퓨터 그래픽스 분야에서는 한정된 자원의 컴퓨터를 사용해 빛을 실제와 같이 표현하기 위해 많은 노력을 해왔다. 물론 십몇년 전까지는 실제와는 거리가 멀었다. 대표적인 예전의 컴퓨터 그래픽을 나타내는 것은 아래와 같은 영상이다.

{% youtube "https://www.youtube.com/watch?v=oRL5durPleI" %}

Windows 95 시절의 화면 보호기 영상인데, 컴퓨터 그래픽인 것을 알 수 있는 부분은 맨 마지막에 OpenGL 이라고 쓰여져 있는 부분이다. 물론 이는 OpenGL 이 나온지 얼마 안되었을 때이고 95 년을 기준으로 따졌을 떄 20년이 지난 것들이다. 게다가 여기서는 라이팅도 없다. 하지만 20년이 지나고.. 현재로 돌아와서 최근에 와서는 꽤 실제와 비슷한 것들이 많이 나왔다. 아래 영상을 보자.

{% youtube "https://www.youtube.com/watch?v=9v4XM8y-8fs" %}

최근에 공개된 파크라이5 의 트레일러 영상이다. 자세히 보면 조금은 인위적인게 보이지만 실시간 3D 렌더링으로 이 정도를 나타낸건 지금도 혀를 내두를만한 기술들이 총 집약되어 여태까지 나온 게임들 중에 최고의 실시간 렌더링의 퀄리티를 보여준다. 특히 빛에 대한 묘사들이 더욱더 실제와 비슷하게 느끼게 해준다.

이 글에서는 위 영상처럼 발전하기 까지의 여러가지 기본적인 렌더링 기법과 라이팅 기법에 대해서 알아볼 것이다. 최신 기술들도 중요하지만 최신 기술들을 이해하기 위해서도 여태까지의 기술들을 알아야 하고, 그 와중에서도 이전에 쓰이던 것을 그대로 쓰는 것도 있기 때문이다.

<!-- more -->

필자는 여태까지 프로그래밍과 여러 아키텍쳐를 공부할 때 전체적인 개괄을 먼저 공부하고, 자세한 것들을 하나하나 공부하는 하향식 공부방법을 택해왔다. 그도 그럴수 밖에 없는 이유가 있다. Unity 만 예로 들어도 가장 맨 처음에는 로드맵을 보고 공부를 시작한다. 그 로드맵에는 디테일한 내용들은 없고 전부다 겉핡기 수준의 지식들만 노출되어 있다. 로드맵을 전부 보고난 후에 게임을 만들면서 필요한 기능들을 하나하나 들여다보기 시작한다.

이와 같이 렌더링 기술들을 익히기 위해서는 전체적인 과정을 본 다음에 공부하는 것이 좋다. 아래에 렌더링이 한틱마다 이루어지는 과정을 보여주는 그림이 있다.

![Vulkan pipeline](/images/vulkan_pipeline.svg){: .center-image}

위 사진은 최근에 나온 Vulkan API 의 렌러링 파이프라인을 그려놓은 사진이다. 근데..  음.. 굉장히 복잡하다. Vulkan 은 DX12 에 대항하기 위해 만들어진 멀티 플랫폼 Graphics API 로써 Graphics API 를 통하여 이전 버젼의 API 들 보다 굉장히 많은 것을 프로그래머가 제어할 수 있게 해주는 API 다. 그러니 복잡할 수 밖에 없다. 하지만 우리는 자세한 것 보다 대략적인 큰 그림을 봐야하기 때문에 다른 간단한 그림을 보자.

![TesselPlusPipe](/images/sm40_tess.png){: .center-image}

이전의 Vulkan 파이프라인과는 다르게 간단하게 표현된 그림이다. DirectX10 의 렌더링 파이프라인을 간단하게 보여준다. 연두색은 프로그래머가 제어할 수 있는 것이며(_Programmable_) 주황색은 프로그래머가 제어할 수 없는 것들이다. 물론 중간 과정에는 꽤나 복잡한 작업들이 이루어 진다. 하지만 우리가 주목할 것들은 연두색으로 된 _Programmable_ 쉐이더들이다.

GPGPU 기능을 사용하지 않는 한 거의 대부분의 라이팅 처리는 Vertex, Geometry, Fragment 쉐이더를 사용해서 처리를 한다. 이 세가지의 쉐이더 조합은 나온지 몇년이 지났음에도 불구하고 엄청많이 사용되는 쉐이더 모델이다.이제 라이팅에 대하여 알아보자.

맨 처음에 등장한 라이팅 기법은 정점 쉐이더에서 모든 정점 마다 빛이 반사되는 값을 계산하여 처리해주는 _forward lighting_ 이라는 기법이다. 이 기법은 단순하고 오래된 전통적인 기법이며 VR 이나 모바일 같은 GPU 의 퍼포먼스가 조금 딸리는 분야에서 많이 사용된다.

![forward lighting](/images/forward-v2.png){: .center-image}

_forward lighting_ 방식은 근데 중요한 문제가 하나 있었다. 모든 오브젝트의 정점마다 모든 라이팅을 전부 계산하기 때문에 오브젝트의 수와 라이팅의 갯수가 많으면 많을 수록 렌더링되는 속도는 현저하게 느려졌다. 그래서 최대한 그리는 정점의 갯수를 줄이기 위해 여러 기법들이 나왔다. 아주 기본적인 기법은 _Frustom Culling_ 이라는 기법이다. 카메라에서 보이는 것들만 그린다는 아이디어로 구현되어 있으며 간단한 충돌처리를 이용해서 구현할 수 있다.

![Frustom Culling](/images/frustum_culling.png){: .center-image}

이 방식은 Perspective 형식으로 화면을 렌더링하는 카메라로 그릴 오브젝트와 안그릴 오브젝트를 구분하는 그림이다. 주황색은 그릴 오브젝트들 이며 회색은 안 그릴 오브젝트 들이다. 여기서 더 발전해서 가려져서 안보이는 오브젝트들을 그리지 않는 _Occlusion Culling_ 이라는 기법이 나왔다.

카메라에서 가려지는 오브젝트를 아예 그리지 않는 것이다. 이 기법은 Unity 에서도 지원한다. [Unity : Occlusion Culling](https://docs.unity3d.com/kr/current/Manual/OcclusionCulling.html) 여기를 보면 사용 방법들을 참조할 수 있다. Unity 의 _Occlusion Culling_ 은 에디터상에서 정육면체들을 미리 설정해서 보이는 정육면체 단위로 메쉬 렌더러를 끄거나 킨다. 조금 이상하다고 느껴지는 점은 왜 맨처음에 귀찮게 설정을 해주어야 하며, 정육면체 단위로 공간을 잘라서 판단하는게 이상하다고 느껴진다. 이렇게 하면 연산량이나 여러모로 귀찮을 것 같기 때문이다. 하지만 이는 절대적인 연산량들을 줄이고 간편하게 _Occlusion Culling_ 을 구현하기 위한 일종의 꼼수다. 미리 영역을 계산하는 것은 실시간으로 할 필요가 없이 미리 공간을 정해놓고 공간에 해당되는 메쉬 렌더러를 설정하는 과정이고, 정육면체 나눈것은 가려지는 것들을 판단하게 실시간으로 빠르게 계산하기 위한 것이다.

결국 절대적인 라이팅 연산량을 줄이고자 여러 기법들이 사용되었다. 하지만 근본적인 _forward lighting_ 의 문제인 라이트의 종류와 갯수는 여러 문제를 일으켰고 다른 기법(다시말해 꼼수) 들을 사용해 어떻게든 구현하였다.

하이엔드 게임들은 꽤 많은 실시간 라이팅을 사용해 오브젝트의 디테일을 살렸다. 하지만 기존의 라이팅 방식은 논리적 라이트의 갯수에 따라 엄청난 부하를 일으켰고 문제를 해결하기 위해 사람들은 다른 라이팅 방식을 고안해냈다. 이름은 _deferred lighting_ 이다. 사실 이 _deferred lighting_ 이 고안되기 전에는 _forward lighting_ 이라는 단어도 없었다. 단지 개념이 한개가 더 추가되어 두 라이팅 개념을 다르게 통칭하기 위해 서로 이름이 붙혀진 것이다. 그래서 _deferred lighting_ 은 어떤 식으로 _forward lighting_ 의 라이트의 갯수의 문제를 해결했는지 알아보자.

_forward lighting_ 에서는 픽셀 쉐이더에서 라이팅의 처리를 했었다. 그래서 _deferred lighting_ 은 정점 쉐이더는 기본적인 위치 변환만 한 후 새롭게 추가된 지오메트리 쉐이더에서 라이팅을 계산하기 위한 데이터들만 전부 넘겨주어 계산을 하지 않고 픽셀 쉐이더 이후에 넘어온 라이팅에 대한 데이터 전부를 뒤로 쭈~욱 넘겨서 마지막에 픽셀별로 처리해서 라이팅의 연산 비용을 줄인셈이다.

![deferred lighting](/images/deferred-v2.png)

_forward lighting_ 에 비해 많은 수의 라이팅을 쓸 수 있고 이미 그려놓은 데이터들을 가져다가 후처리를 할 수도 있고, HDR 등 여러 기법들을 사용할 수 있다. 그렇지만 _deferred lighting_ 은 만능이 아니다. MRT 를 사용하므로 기본적으로 메모리 공간을 많이 잡아먹고, 많이 쓰일 당시에는 MSAA 를 사용하기에 상당히 애매했었다. 그리고 조금이라도 투명한 오브젝트를 처리하기에 굉장히 애매했다. 또한 전체적으로 _forward lighting_ 에 비해 넘어가는 인자의 크기가 크므로 전체적인 부담이 심했다.

하드웨어도 꽤나 빠르게 진화하는 PC 플랫폼에서는 _deferred lighting_ 구조가 더 성능이 좋은 경우가 훨씬 많았지만 모바일 같은 GPU 의 성능도 별로 안좋고 화면만 엄청 큰(=필레이트가 많이 필요함) 환경에서는 부하가 걸릴 수 밖에 없다. 모바일에서는 런타임에서 최대한 기능을 조금만 쓰기 위해 _forward lighting_ 을 사용하고 빛에 대한 처리는 여러 꼼수를 사용했다.

아주 가장 기초적인 꼼수인 _light map_ 이라는 기법을 사용했는데 원리는 상당히 간단하다. 버텍스별 라이트의 정보를 전부 텍스쳐로 저장해두어 uv 좌표를 사용해 텍스쳐 값을 합쳐주어 사용하는 것이다. 이는 노말맵과 비슷한 원리이다. 그래서 필요한 빛 데이터들을 라이트맵을 이용하여 사용했다.

<!--
  phong reflecton = Ambient Light, Diffuse Light, Specular Reflection
  physics based rendering = reflection + albedo + refraction
    sRGB
    gamma correction
    bdrf vs bsrf vs btdf

  screen space ambient occlusion
  per-vertex ambient occlution

  global illumination

  shadow mapping
  raytracing shadow
-->

## 참조

 - [Unified shader model](https://en.wikipedia.org/wiki/Unified_shader_model)
 - [GameDev : forward rendering vs deferred rendering](https://gamedevelopment.tutsplus.com/articles/forward-rendering-vs-deferred-rendering--gamedev-12342)
 - [Wikipedia : Deferred shading](https://en.wikipedia.org/wiki/Deferred_shading)
 - [LearnOGL : Deferred shading](https://learnopengl.com/#!Advanced-Lighting/Deferred-Shading)
 - [Ambient Light, Diffuse Light, Specular Reflectio](http://celdee.tistory.com/525)
 - [PBR For Artist](http://m.blog.naver.com/blue9954/220404249147)
 - [Mikkelsen's Blog : FPTL](http://mmikkelsen3d.blogspot.kr/2016/05/fine-pruned-tiled-lighting.html)
 - [Slideshare : hi-z occlusion culling](https://www.slideshare.net/dgtman/hierachical-z-map-occlusion-culling)
