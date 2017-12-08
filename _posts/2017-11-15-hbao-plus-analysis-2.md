---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - analysis
  - hbao+
  - bilateral_filter
---

__HBAO+ 3.1 버젼을 기준으로 글이 작성되었습니다.__

이전 [hbao plus analysis 1]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-analysis-1 %}) 글에서 _HBAO+_ 에서 _Linearize Depth_ 와 _Deinterleaved Texturing_ 에 대해서 알아보았다. 이번 글에서는 _HBAO+_ 의 핵심 알고리즘인 _Horizon Based Ambient Occlusion_ 와 AO 블러에 사용되는 _Cross Bilateral Filter_ 에 대해서 알아볼것이다.

## Horizon Based Ambient Occlusion

_Horizon Based Ambient Occlusion_ 은 xy 평면과(horizon) Depth 값을 사용해서 _AO_ 를 계산한다. 슬라이드에서 가져온 일부를 보자.

<br/>
![Horizon Mapping](/images/hbao_siggraph08_05.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/presentations/2008/SIGGRAPH/HBAO_SIG08b.pdf">Siggraph 2008 : Image-Space Horizon-Based Ambient Occlusion</a>
</center>
<br/>

해당 슬라이드에서는 xy평면을 단순하게 1차원인 x축만으로 나타냈다. _HBAO_ 는 그림에 나오는 _horizon angle_ 을 사용하여 _AO_ 값을 구한다. 자세한 방법은 아래 슬라이드를 보자.

<br/>
![Horizon-Based AO](/images/hbao_siggraph08_12.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/presentations/2008/SIGGRAPH/HBAO_SIG08b.pdf">Siggraph 2008 : Image-Space Horizon-Based Ambient Occlusion</a>
</center>
<br/>

슬라이드에서는 표면의 접선을 나타내는 _Tangent_ 벡터와 _Horizon_ 벡터를 사용해서 _sin_ 의 차이로 _AO_ 를 계산한다고 설명되어 있다. _Horizon_ 벡터는 _Depth_ 와 화면의 좌표를 구해서 샘플링하는 위치값을 구하고 기준이 되는 위치값의 차이를 통해 구한다. _HBAO+_ 코드에서는 입력을 받은 _Normal_ 벡터와 _Horizon_ 벡터에 _dot_ 을 사용해 _cos_ 값을 구하고 변환해준다. 이렇게 한번 _AO_ 값을 구한다.

보다 정확한 _AO_ 값을 구하기 위해서는 전방위로 탐색할 필요가 있다. 정해진 방향으로 샘플링을 해도 오차가 생길 수 있고 완전히 랜덤하게 방향을 정해도 부정확한 결과를 얻을 수 있다. 그래서 _HBAO_ 는 랜덤하게 방향을 정하나 그 방향 벡터를 정해진 각도로 돌려주어 그나마 정확한 결과를 얻으려 한다. 슬라이드를 보고 넘어가자.

<br/>
![Sampling the Depth Image](/images/hbao_siggraph08_14.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/presentations/2008/SIGGRAPH/HBAO_SIG08b.pdf">Siggraph 2008 : Image-Space Horizon-Based Ambient Occlusion</a>
</center>
<br/>

핵심적인 개념은 모두 설명했지만 만족할만한 결과를 얻기 위해 여러가지 보정 방법들이 필요하다. 그래서 _HBAO_ 에서는 두가지 보정을 해주는 개념을 설명한다. _HBAO_ 는 방향을 설정해주고 해당 방향으로 한번만 샘플링 하는게 아니라 여러번 샘플링 한다. 그러므로 거리에 따른 감쇠(attenuation)가 필요하다. 방법은 간단하다. _AO_ 를 계산할때 구했던 _Horizon_ 벡터의 크기에 따라서 _AO_ 값을 줄여준다. 나머지 한가지는 _Horizon_ 벡터와 _Tangent_ 벡터를 이용해 구하는 실질적인 _AO_ 값에 _Bias_ 로 낮은 _AO_ 값들을 무시하는 방법이다. _Bias_ 가 없이 _AO_ 를 생성하게 되면 노이즈가 생기기 때문이다. 또한 _Bias_ 로 생긴 수학적 오차는 코드에서 따로 보정해주기 때문에 크게 문제는 없다.

## Cross Bilateral Filter

_SSAO_ 의 결과에는 일반적으로 블러를 먹이게 된다. 대부분 근사에 기반한 계산이기 때문이다. _HBAO_ 에서는 _Depth_ 를 이용한 방법을 소개한다. 바로 _Cross Bilateral Filter_ 다.

_Cross Bilateral Filter_ 은 _Gaussian Filter_ 와 비슷한 필터로, _Gaussian Filter_ 는 샘플링할 위치의 거리에 따라 점차 가중치가 줄어드는 필터라면, _Bilateral Filter_ 는 위치에 따라 가중치가 줄어드는게 아닌 각 위치별로 가지고 있는 한개의 스칼라값에 차이에 따라서 가중치를 정하는 필터다. _Cross_ 단어를 붙인 이유는 왼쪽과 오른쪽 방향의 필터와 위와 아래의 필터를 따로하기 때문에 _Cross_ 라는 단어를 붙인 듯 하다. _HBAO+_ 코드에서도 X 축과 Y 축을 기준으로 하는 블러 소스가 나누어져 있다. _HBAO_ 에는 한개의 스칼라 값을 _Depth_ 를 기준으로 계산한다. 그래서 크게 튀는 부분의 결과는 많이 반영하지 않아 전체적으로 뿌옇게 바뀐다.

<br/>
![Sampling the Depth Image](/images/hbao_siggraph08_28.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/presentations/2008/SIGGRAPH/HBAO_SIG08b.pdf">Siggraph 2008 : Image-Space Horizon-Based Ambient Occlusion</a>
</center>
<br/>

# 참조 자료

- [NVidia HBAO+](http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html)
- [Image-Space Horizon Based Ambient Occlusion](http://developer.download.nvidia.com/presentations/2008/SIGGRAPH/HBAO_SIG08b.pdf)
- [Wikipedia : Gaussian Filter](https://en.wikipedia.org/wiki/Gaussian_filter)
- [Wikipedia : Bilateral Filter](https://en.wikipedia.org/wiki/Bilateral_filter)
