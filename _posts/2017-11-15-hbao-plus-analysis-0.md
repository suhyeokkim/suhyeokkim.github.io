---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - analysis
  - hbaoplus
---

게임에서 쓰이는 실시간 렌더링에서 빛과 물체들의 상호작용을 완벽하게 현실적으로 표현하는 거의 불가능하다. 하지만 이를 위해 수십년동안 많은 엔지니어와 연구자들이 노력하여 부분적이고 제한된 환경에서의 빛과 물체의 상호작용을 현실 세계와 비슷하게 따라잡고 있다. 이번 글에서 살펴볼 것은 _Screen-Space Ambient Occlusion(SSAO)_ 기반의 _HBAO+_ 라는 라이브러리에 대해서 알아볼 것이다.

_HBAO+_ 는 NVidia 에서 만든 라이브러리로써, 현재 [_ShadowWorks_](https://developer.nvidia.com/shadowworks) 라는 프로젝트에 포함되어 있다. [_ShadowWorks_](https://developer.nvidia.com/shadowworks) 에는 _HBAO+_ 뿐만 아니라 _ShadowLib_ 이라는 그림자 렌더링을 위한 라이브러리로써 HFTS, PCSS, CSM 등 많은 기능들을 포함하고 있는 라이브러리가 있다. 현재 _ShadowLib_ 은 오픈소스가 아니지만 이번에 알아볼 _HBAO+_ 는 _Github_ 에서 소스를 받을 수 있다. 이에 대한 자세한 사항은 ["Access GameWorks Source on Github"](https://developer.nvidia.com/gameworks-source-github) 에서 확인할 수 있다.

### Ambient Occlusion?

_Ambient Occlusion_ 이란 말은 처음 들어본 사람에게는 생소한 말이지만 한번이라도 들어본 사람들에게는 꽤나 익숙한 말일 것이다. 빠른 이해를 위해 아래 그림을 보자.

<br/>
![Wikipedia : Ambient Occlusion Image](/images/220px-AmbientOcclusion_German.jpg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Ambient_occlusion">Wikipedia : Ambient Occlusion</a>
</center>
<br/>

가장 위의 이미지를 보자. 단순한 렌더링이 아니라 반사를 구현해놓아서 꽤나 사실적이다. 하지만 여기서 더욱더 사실적으로 표현이 가능하다. 중간의 이미지를 보면 _Ambient Occlusion_ 이 무엇인지 쉽게 알 수 있다. 흰색 물체와 흰색 배경과 함께 아래 구석에 어두워진 것을 볼 수 있다. 이를 _Ambient Occlusion_ 이라고 한다.

글로 간단하게 설명하자면 물체가 모이면 좁은 공간이 생기게 되고, 구석이면 구석일 수록 직접 들어오는 빛은 있으나 반사되어 오는 빛이 적어지므로 어두워진다. 이를 말하는 것이바로 _Ambient Occlusion_ 이다. _Ambient_ 는 주변을 뜻하고, _Occlusion_ 은 무언가 가리는 것을 뜻한다. 빛을 가려서 주변에 보이는 것이 어두워지는 것을 말하는 것이다.

보통 _Ambient Occlusion_ 은 개발시에 미리 시간을 들여 계산해 미리 저장해놓은 다음 실시간으로 저장된 데이터를 읽어서 사용하는 _precomputed AO_ 방식으로 사용한다. 이유는 간단하다. 실시간으로 계산되기에는 요즘 컴퓨터로는 연산량을 버틸 수 없어서 그렇다. 월드가 복잡할수록, 넓을수록, 고퀄리티의 _AO_ 를 계산할수록 시간이 대폭 증가한다. 하지만 이는 물체와 물체간의 _AO_ 를 계산할때의 이야기이다.

### Screen-Space AO?

_Deffered Rendering_ 이 많이 쓰이면서 이를 위한 많은 기술들이 연구되었다. _Deffered Rendering_ 의 대부분의 기술들은 이름앞에 보통 _Screen-Space_ 라는 단어를 달고 나왔다. _Screen-Space_ 란 _Geometry Stage_ 아닌 _Rasterizer Stage_ 로 넘어가서 처리되는 부분을 말한다. 말 뜻대로 해석한다면 2D 이미지의 공간이라는 뜻도 되겠다. 다만 _Pixel Shader_ 로 넘어간다고 해서 _Depth(Z value)_ 가 사라지지는 않기 때문에 이를 온전히 2D 공간이라고도 볼 수는 없다. 실제 좌표계는 _Clipping-Space_ 로 되어 있을 것이다.(x,y,z 가 -1 ~ 1 범위의 좌표로 되어있는 공간, Driver API 에 따라 조금씩 다르다.) 쉽게 이해하기 위해 아래 그림을 보자.

<br/>
![Deffered Rendering](/images/DeferredLighting.jpg){: .center-image}
<center>출처 : <a href="http://tower22.blogspot.kr/2010/11/from-deferred-to-inferred-part-uno.html">From Deferred to Inferred, part uno</a>
</center>
<br/>

위 그림은 _Deffered Rendering_ 의 중요한 특징을 나타내는 그림이다. 이 데이터들을 _GBuffer_ 라고 한다. 저 결과들은 _Multi Render Target_ 을 통해 한 _Pixel Shader_ 에서 나온 결과물들이다. 즉 한 장면을 렌더링해서 2D 버퍼안에 데이터들을 픽셀별로 저장한 것이다. 각각 저마다 필요한 정보들을 담고 있다. 우리가 알아볼 _Screen-Space AO_ 또한 이런식으로 데이터를 처리한다. 위 그림에는 나와있지 않지만 하드웨어 차원에서 _Depth Buffer_ 를 지원한다. _Pixel Shader_ 를 실행한 후 알아서 _Depth Buffer_ 에 Z 값을 저장해준다. _Screen-Space AO_ 는 _Depth Buffer_ 를 이용하여 계산한다. 물론 _Depth Buffer_ 뿐만아니라 _GBuffer_ 에서 _Normal_ 데이터까지 사용하여 할 수도 있다.

하지만 _SSAO_ 는 정공법이 아니다. 모든 _AO_ 를 표현할 수 없으며 디테일한 _AO_ 밖에 표현하지 못한다. 그렇기에 이는 부가적인 방법으로 사용되어야 한다. _SSAO_ 를 활용하기 가장 좋은 장면은 화면에서 작게 표시되는 오브젝트들이 조밀하게 많이 있을 떄나 그려지는 오브젝트의 디테일이 많을 때다. 이럴때 _SSAO_ 를 표현하면 괜찮은 결과가 나온다.

<br/>
![Unity Technology : SSAO](/images/0cf69542-8ff5-422a-8d01-f11bd65ab62e_scaled.jpg){: .center-image}
<center>출처 : <a href="https://forum.unity.com/threads/ssao-pro-high-quality-screen-space-ambient-occlusion.274003/page-5">Unity Forum</a>
</center>
<center></center>
<br/>

게임에서는 조금이라도 복잡한 메시를 쓸 수 밖에 없기 때문에 결국 왠만한 게임에는 _SSAO_ 를 넣는 것이 괜찮은 선택이 된것이다. 하지만 초기에 제안된 _SSAO_ 구현물들은 대부분 꽤나 시간을 잡아먹었었다. 그래서 시간에 따른 선택이 되었지만 _HBAO+_ 와 같은 개량된 기법이 여러개 등장하여 퍼포먼스를 다른 곳에 쓸 수 있게 되었다. [Geforce : HBAO+ Technology](https://www.geforce.com/hardware/technology/hbao-plus/technology) 에서 _SSAO_ 테크닉에 따른 벤치마킹을 볼 수 있다.

<br/>
![benchmark](/images/hbao_bench.png){: .center-image}
<center>출처 : <a href="https://www.geforce.com/hardware/technology/hbao-plus/technology">Geforce : HBAO+ Technology</a>
</center>
<center></center>
<br/>

우리가 살펴볼 것은 가장 아래에 있는 _HBAO+_ 에 대한 것들이다. _Resolution_ 은 _Depth Buffer_ 의 해상도를 뜻한다. 당연히 큰 사이즈여야 디테일한 것까지 표현할 수 있다. 가장 왼쪽에 있는 것은 시간이다. _HBAO+_ 가 2.4ms 로 조금 느리지만 그 오른쪽에 있는 _Occlusion Samples Per AO Pixel_ 의 숫자와 같이 비교하면 이야기가 다르다. 이는 한 픽셀별로 몇번 다른 텍스쳐의 데이터 샘플링 숫자다. _HBAO_ 는 4번만 하지만, _HBAO+_ 는 이의 9배인 36번이다. 샘플링을 많이하게 되면 더욱더 사실적인 _SSAO_ 를 표현할 수 있다. 샘플링 숫자에 비하면 시간은 내어줄 수 있는 자원인 것이다.

이 글에서는 _HBAO+_ 를 분석하기 전 배경이 되는 개념에 대해서 알아보았다. 다음 [hbao plus anatomy 1]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-anatomy-1 %}) 에서는 _HBAO+_ 라이브러리에 대한 본격적인 분석을 해보려고 한다.

# 참조 자료

 - [Wikipedia : Ambient Occlusion](https://en.wikipedia.org/wiki/Ambient_occlusion)
 - [NVidia Developer Program](https://developer.nvidia.com/developer-program)
 - [Geforce : HBAO+ Technology](https://www.geforce.com/hardware/technology/hbao-plus/technology)
 - [한국 지포스 포럼 : HBAO+](https://forums.geforce.co.kr/index.php?document_srl=12616&mid=geforce)
