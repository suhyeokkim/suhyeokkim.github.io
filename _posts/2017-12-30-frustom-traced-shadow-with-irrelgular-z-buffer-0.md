---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - fts
---

[Percentage-Closer Filtering Shadows]({{ site.baseurl }}{ post_url 2017-12-27-percentage-closer-soft-shadows }) 에서 _PCF_ 를 응용한 _PCSS_ 라는 _Soft Shadow_ 를 나타내는 기법에 대해서 알아보았다. 이번 글에서는 여태까지 알아본 것들에 비해 굉장히 최근에 나온 기법인 _Frustom-Traced Shadow_ 에 대해서 알아볼것이다.

해당 기법은 2015년에 _Siggraph_, _Interactive 3D_ 같은 컨퍼런스에서 발표되었으며, 현재 _Tom Clansy's the Division_ 에 _PCSS_ 와 혼합된 형태(_Hybrid Frustom Traced Shadow_)로 적용되어 있다. _Frame Rate_ 에 조금 영향을 미쳐 대부분의 게이머들은 아직은 _HFTS_ 를 사용하지 않는듯 하다.([Reddit : Nvidia HFTS (The Division)](https://www.reddit.com/r/nvidia/comments/49idz3/nvidia_hfts_the_division/)) 하지만 컴퓨팅 파워가 늘어나는 것을 가정한다면 앞으로 하이엔드 게임의 주 옵션이 될수도 있겠다.

이 기법의 저자는 _Shadow Map_ 처럼 따로 붙은 기법없이 _Aliasing_ 이 없어야 했으며, 현세대의 GPU 와 해상도를 _Interactive_ 하게 지원하는 것이 완벽한 _Hard Shadow_ 를 목표로 _FTS_ 를 고안했다. 가장 많이 쓰이는 _Shadow Map_ 기법은 공간적(_Light-Space_ 와 _Clipping-Space_ 의 _Discretize_ 된 결과의 차이), 일시적인(필터링이 필요한 _Aliasing_)인 문제들이 산재한다. 이는 이 기법을 고안한 시발점이였다.

_FTS_ 의 이론적인 뿌리를 정하기 위해 저자는 여태까지 존재하는 여러 기법을 언급한다. 빛을 하나의 직선단위로 시뮬레이팅 하는 _Ray-Tracing_, 볼륨을 통한 각각의 폴리곤들을 테스트 하는 _Shadow Volume_, _Irregular Z-Buffers_ 를 언급했다.

_Shadow Volume_ 은 3차원상으로 _Shadow_ 가 생기는 부분을 정해 그 부분을 테스트해서 _Shadow_ 를 정해주는 기법이다. 이는 _Shadow Map_ 보다 픽셀 단위로 처리할 수 있지만, 여러 단점이 있다고 한다. 한번에 해결되는 깔끔한 방법이 없으며, 보이지 않는 부분도 처리하기 때문에 _Fill-Rate_ 를 많이 소모한다. 게다가 처리 자체가 간단하지 않기 때문에 개발자들도 많이 쓰는 기법이 아니라고 한다. 필자도 _Shadow Map_ 에 대한 자료는 굉장히 많이 봤지만 _Shadow Volume_ 은 거의 본적이 없다.

<br/>

![](/images/NVidia_ShadowVolume.jpg){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/books/HTML/gpugems/gpugems_ch09.html">GPU Gems : Efficient Shadow Volume Rendering</a>
</center>
<br/>


_Ray-Tracing_ 은 빛을 직선 단위로 시뮬레이팅을 하는 기법으로, 계산 비용 자체가 비싸기 때문에 하드웨어와 구조에 굉장히 의존적이라고 한다. 게임에서도 쓰일 수 있는 기법이 있었지만 다른 후보에 밀려났다. 바로 _Irregular Z-Buffer_ 다.

_Shadow Map_ 은 _Light-Space_ 에서 만들어진 _Z-Buffer_ 다. _IZB_ 는 여러가지 형태로 구현될 수 있지만 이 기법에서는 _Z-Buffer_ 의 변형된 기법 : _Accumulate Buffers_, _A-Buffer_ 를 선택했다. 기존의 _Z-Buffer_ 가 _Depth_ 한가지만 가지고 있는 _Buffer_ 를 말한다면 _A-Buffer_ 는 두개 이상의 데이터를 저장해 누적시키는(_Accumulate_) _Buffer_ 를 말한다. 이 기법에서 _IZB_ 는 _Light-Space A-Buffer_ 형태를 가지게 했다. 이 선택은 꽤나 중요한 이유가 있다. _A-Buffer_(_IZB_) 의 각각의 텍셀들은 실제 그려질 픽셀에 대한 정보들이 저장한다. 데이터가 _Irregular_ 하고, 접근도 불규칙적이기 때문에 퍼포먼스도 굉장히 편차가 크다고 한다. [^1]

### Irregular Z-Buffer

이름를 보면 _Irregular Z-Buffer_ 는 _Z-Buffer_ 의 조금 다른 버젼이라고 추정할 수 있다. 하지만

<!--
    Irregular Z-Buffer
    Frustom Test for AntiAliasing
-->

## 참조

 - [Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows](http://cwyman.org/papers/tvcg16_ftizbExtended.pdf)
 - [Wikipedia : Irregular Z-Buffer](https://en.wikipedia.org/wiki/Irregular_Z-buffer)
 - [cywman.org : HFTS Presentation Video](http://cwyman.org/videos/sig1657-chris-wyman-magic-behind-gameworks-hybrid-frustum-traced-shadows-hfts.mp4)

[^1]: 각각의 텍셀들이 여러 픽셀들의 정보를 저장하게 되면 텍셀별로 데이터가 다르고, GPU 에서 병렬적으로 데이터를 처리할 때, 각각의 데이터의 처리량이 다르게 되면 결국 가장 처리시간이 긴걸로 맞춰지게 된다. 이를 Stall 이라고 부른다.
