---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - hlsl
  - analysis
  - hbao+
---

__HBAO+ 3.1 버젼을 기준으로 글이 작성되었습니다.__

이전 [hbao plus analysis 2]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-analysis-2 %}) 글에서 _Horizon based ambient occlusion_ 와 _Cross Bilateral Filter_ 대해서 알아보았다. 이번 글에서는 부록의 느낌으로 _HLSL_ 코드를 읽으면서 생소했던 기타 기법들에 대해서 써볼 것이다.

첫번째로 _Full Screen Triangle_ 이라는 기법이다. 알고마면 굉장히 단순한 개념으로, 화면을 모두 덮는 한개의 삼각형을 그려서 모든 픽셀에 쉐이더를 돌릴 수 있게 해주는 기법이다. 아래 슬라이드를 보면 쉽게 이해가 갈것이다.

<br/>
![Full Screen Triangle](/images/vertex-shader-tricks-by-bill-bilodeau-amd-at-gdc14-14-638.jpg){: .center-image}
<center>출처 : <a href="https://www.gdcvault.com/play/1020624/Advanced-Visual-Effects-with-DirectX">GDC 2014 : Vertex Sahder Tricks</a>
</center>
<br/>

단순하지만 처음 봤을 때는 조금 신박하게 느껴질 수도 있다. 두번째로는 모든 계산에 최대한 _HLSL Intrisic_ 을 사용한다. 특히 벡터와 벡터사이의 거리를 계산할때 _dot product_ 를 써서 하는게 정말 많았다. 어셈블리 레벨에서 달라지는것 같긴하나 정확한 이유는 알지 못했다. 추측해보면 GPU 에서 해당 명령어가 있지 않을까.. 라고 생각한다.

세번째도 위의 것과 비슷하다. 대부분의 데이터에 _MAD_ 방식을 사용해서 계산한다. 하지만 이는 거의 공식적으로 정해진게 있다. [MSDN : mad  function](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471418.aspx) 레퍼런스에서도 나오듯이 어떤 GPU 에서는 위에서 추측한대로 하드웨어에서 지원하는 명령어라고 한다.

> ...
> Shaders can then take advantage of potential performance improvements by using a native mad instruction (versus mul + add) on some hardware.
> ...

또한 _HBAO+_ 소스에서 찾은 주석에는 _GK104_ 부터 특정 구간에서 10% 퍼포먼스 이득이 있다고 쓰여져 있다.

네번째는 나누기를 절대 쓰지 않는다. 나머지 연산(mod, A % B)는 간혹 쓰이지만 나누기는 절대로 쓰이지 않았었다. 혹시라도 필요하다면 전부 _Constant Buffer_ 에 CPU 에서 역수를 취해서 넘겨주는 방식으로 되어 있었다. 이도 역시 하드웨어에서 동작하는 부분을 알고 짠듯하다.

다섯번째는 _HLSL_ 코드를 _cpp_ 소스에 _include_ 하여 _Constant Buffer_ 값을 갱신하는 코드였다. 여태까지 예전의 _DirectX_ 소스만 보거나 _Unity_ 에서만 작업을 해서 그런지 이런 기능은 굉장히 낯설었다.

# 참조 자료

 - [NVIDIA HBAO+](http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html)
 - [GDC 2014 : Vertex Sahder Tricks](https://www.gdcvault.com/play/1020624/Advanced-Visual-Effects-with-DirectX)
 - [MSDN : mad function](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471418.aspx)
