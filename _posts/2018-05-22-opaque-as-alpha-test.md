---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - rendering
  - alphatest
  - shader
---

_Shader_ 에서 샘플링하는 _Texutre_ 에서 _Alpha_ 값을 가지고 있어, _Alpha_ 을 참조해서 실제 픽셀에 출력을 하는지 안하는지를 결정하는 것을 _Alpha Test_ 라고 한다. 이런 _Material_ 이나 _Texture_ 를  _Cutout_ 이라고 통칭하는 경우가 많다.

보통 게임에서의 _Alpha Test_ 를 사용하는 것들은 나무, 풀 같은 식생들(_Vegetation_)이 있고, 중간에 구멍이 뚫린 펜스같은 것들도 존재한다. 자연을 배경으로하는 게임의 경우에는 식생들이 굉장히 많기 때문에 _Alpha Test_ 를 사용하는 _Shader_ 가 굉장히 많이 사용될 것이다.

<br/>
![Wikipedia : Single-precision floating-point format](/images/1_8EKqWSOOPXaTrDHVFTACJg.png){: .center-image}
<center>출처 : <a href="https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f">Anti-aliased Alpha Test: The Esoteric Alpha To Coverage</a>
</center>
<br/>

하지만 _Alpha Test_ 는 굉장히 큰 단점이 있다. 고정된 화면 해상도에서 물체가 작게 표현되면 물체를 표현할 수 있는 픽셀의 숫자가 많이 작아진다. 물체를 표현하는 픽셀의 수가 작아지게 되면 일반적으로 해당 넓이에 맞게 생성된 _Texture_ 의 _Mip-level_ 에 접근한다. 중간의 _Alpha Test_ 그림을 보면된다.

<br/>
![Wikipedia : Single-precision floating-point format](/images/1_zNbZFiJXjcqqyTkM9eEt7w.gif){: .center-image}
<center>출처 : <a href="https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f">Anti-aliased Alpha Test: The Esoteric Alpha To Coverage</a>
</center>
<br/>

실제로는 양 옆의 물체들처럼 자연스럽게 표현이 되야하지만 일반적인 _Alpha Test_ 를 사용하게 되면 위와 같은 현상에 마주치게 된다. 이는 굉장히 끔찍한 현상이다. 실제 게임을 해보거나, 만들어본 사람이라면 안다. 대부분의 픽셀에 나무가 표현되고, 잎사귀들이 저런식으로 자글자글 거린다면 약간의 불쾌함이 느껴진다. VR 이라면 더욱..

그래서 급하게 대처방안으로 나온 것이 위 그림의 오른쪽에 나오는 _Alpha to Coverage_ 라는 방법이다. 이는 하드웨어 _MSAA_ 를 픽셀 쉐이더의 결과를 통해 자동으로 해주는것으로, _MSAA_ 의 퍼포먼스와 비례한다. _MSAA_ 는 성능이 영 좋지않아 안쓰는 경우가 꽤 많이 존재하기 때문에 _Alpha to Coverage_ 는 절대적으로 사용할 수 있는 방법은 아니다. 게다가 엄청나게 많은 나무를 _Alpha to Coverage_ 를 쓴다면.. 성능은 안봐도 뻔하다.

앞서 말한 _Alpha Test_ 은 _Material_, _Shader_ 별로 고정된 _Alpha_ 값을 설정해 그 이하가 되면 _Pixel Shader_ 에서 결과를 내놓지 않게 하는(_Discard_) 방법이였다. _Alpha Test_ 의 문제는 샘플링한 _Alpha_ 값이 가끔 극단적으로 낮아서 _Discard_ 되는 것인데, 이를 간단하게 해결하기 위해 요상한 방법이 등장했다.

바로 _Stochastic test_ 라는 방법이다.  

<br/>
![NVidia deverloper : Hashed Alpha Testing](/images/stochastic_sampling.png){: .center-image}
<center>출처 : <a href="https://developer.download.nvidia.com/assets/gameworks/downloads/regular/GDC17/RealTimeRenderingAdvances_HashedAlphaTesting_GDC2017_FINAL.pdf?pUIX8DXxfad7mL4zB3GOthX3r5IgGao9UWxYuYb3q9h10RXrQeYko-dEuJXJxt1hhsI9J_9KJDcCYGeWWksxlaHTrXSE825D_3izja7LUFOtzhaeBUqpn7qbwXaaGlLdbipjE3PeI3e2IMn45mQAA3OV2PD-kG2y9cecTaWE2uum2uwdHgyn0nhYiLOvlOsrUzewbK5REH7vAm3-lNWzxehw_5Tphg">NVidia developer : Hashed Alpha Testing</a>
</center>
<br/>

위 그림에서 위쪽에 있는 것이 일반적인 _Alpha Test_ 인데, _color.a_ 는 텍스쳐에서 샘플링한 _Alpha_ 값, _ατ_ 는 _Alpha Test_ 를 위한 고정된 _Alpha Threshold_(_알파한계_)다. 밑의 코드에서 _drand48_ 이 나타내는 것은 단순한 0 ~ 1 사이의 랜덤값이다. 즉 랜덤하게 _Alpha Threshold_ 를 설정해주어 물체가 멀어져서 평균 _Alpha_ 값이 낮아질 때도 픽셀이 _Discard_ 되지 않도록 하는 것이다. 하지만 이는 굉장한 눈아픔? 반짝거림? 을 유발한다. 범위를 지정해주지 않았기 때문에 이전 프레임에서 출력된 픽셀이 다음 프레임에서는 출력되지 않을 수도 있다. 이렇게 각 프레임마다 상황이 달라서 생기는 현상앞에 _Temporal_ 을 붙인다. _Stochastic Alpha Test_ 의 문제는 _Temporal Flickering_ 이라고 할 수 있겠다.

_Temporal Flickering_ 이 없는, _Temporal Stability_(임시적 안정성) 을 확보하기 위해서는 _Alpha Threshold_ 를 이러저리 튀지 않게해야 했고, 이를 위해 특정 값에 따라서 _Hash_ 값을 생성하는 방법이 고안되었다. 이 방법은 _Hashed Alpha Test_ 라는 이름으로 작년에 공개되었다.

## Hashed Alpha testing

기본적으로 랜덤 값(난수) 생성은 제대로된 난수생성이 아닌, 특수한 식을 사용해서 의사 난수 생성 방법을 이용하는데, _Hash_ 를 이용한 난수생성은 일반적으로 많이 쓰인다고 한다. _Hashed Alpha Testing_ 은 _Hash_ 를 생성하기 위한 _Key_ 값을 선정하는데 조심스러웠다고 한다.

_Key_ 로 선정될 수 있는 후보는 _Texture Coordinate_, _World-Space Coordinate_, _Ojbect-Space Coordinate_ 이 세가지 였다고 한다. _Texture Coordinate_ 는 가끔 없는 경우가 있어 제외하였고, _World-Space Coordinate_ 는 정적 물체에는 원하는대로 동작하지만, 동적 물체의 경우에는 문제가 있었다고 한다. 결국 남은건 _Ojbect-Space Coordinate_ 가 남게 되었다.

_Ojbect-Space Coordinate_ 의 _X,Y,Z_ 세 좌표를 모두 이용하게 되는데, 이는 _X,Y_ 두개만 이용하게 되면 _Hash_ 값이 _Screen-Space_ 에서 생성되어 다른 물체와 겹치게 되면 _Alpha to Coverge_ 같은 효과를 내게되어 3가지 좌표 모두 _Hash_ 생성에 사용된다고 한다.

마지막으로 중요한 포인트는 _Temporal Stability_ 를 확보하는 것이다. 이해하기 쉽게 설명하자면, 아래와 같은 각 픽셀을 나타내는 그리드안에 점이 있다고 가정해보자. 이 점들이 조금씩 움직여서 계속 픽셀안에 있다면, 같은 _Hash_ 값을 사용하여 같은 _Alpha Threshold_ 값을 만들어줘야 한다.

![Subpixel 0](/images/subpixel_0.png){: .center-image}

아래 두 그림의 빨간 점의 위치처럼 원래의 픽셀위치를 벗어나게 된다면 새로운 _Alpha Threshold_ 를 생성해야 하겠지만, 위치가 많이 바뀌지 않는다면 같은 _Alpha Threshold_ 를 사용해 _Flickering_ 을 최대한 줄여야 한다.

![Subpixel 2](/images/subpixel_2.png){: .center-image}

이러한 맥락으로 _Hashed ALpha Testing_ 은 _Temporal Stability_ 를 조금 확보하게 된다. 물론 위의 그림은 이해를 돕기위한 용도로, 실제 코드상에서는 다른 방법을 통해 계산된다. 아래 코드를 보자.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_screenxy.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

위 코드는 픽셀이 가지고 있는 _Object-Space Coordinate_ 의 옆 픽셀과의 차이, 세로에 있는 픽셀과의 차이를 통한 값으로 계산한다. (dFdX, dFdY 의 자세한 내용은 찾아보거나 [What is ddx and ddy]({{ site.baseurl }}{% post_url 2018-03-04-what-is-ddx-and-ddy %}) 에서 볼 수 있다.) 픽셀별로 값의 차이, 즉 근접한 픽셀의 위치 차이값에 따른값(미분값)과 그 값을 이용해 _Object-Space Coordinate_ 값에 곱한 값을 _Key_ 로 두어서 _Alpha Threshold_ 를 계산한다.

마지막에 _Alpha Threshold_ 를 구하는 코드를 보면, _Floor_ 하는, 올림을 해주어 _discrete value_ 로 _Key_ 값을 넣어준다. _Floor_ 가 의미하는 것은, 선형적인 데이터가 아닌 뚝뚝 끊기는 데이터로 만들어 특정한 값을 넘어야 _Key_ 값이 바뀌게 하여 _Hash_ 를 유지해 _Flickering_ 을 방지하는 것이다. 아래 그림은 _floor(x)_ 의 그래프다. 즉 코드의 _pixScale_ 이 크면 클수록 _Hash_ 의 값은 픽셀의 변화에 따라서 빠르게 바뀌고, 작으면 작을수록(0에 가까워질수록) 픽셀의 변화에 따라서 _Hash_ 값이 느리게 바뀔 것이다.

<br/>
![Woflram Alpha : Floor Graph](/images/wolframalpha_floor.gif){: .center-image}
<center>출처 : <a href="http://www.wolframalpha.com/input/?i=floor">Wolframalpha</a>
</center>
<br/>

이러한 방법은 _View-Space_ 를 기준으로 _X,Y_ 좌표가 조금씩 바뀔때는 픽셀끼리의 차이를 계산하기 때문에 안정적이다. 하지만 _Z(Depth)_ 값이 바뀔때는 많은 _Flickering_ 을 일으킬 것이다. 이를 해결하기 위해 아래 코드를 보자.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_screenz0.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

위치의 픽셀별 차이 벡터의 크기를 _discrete_ 시키는 방법도 좋은 아이디어중 하나다. 하지만 이는 빌보드처럼 큰 크기의 판이 다가오게 된다면 끝부분의 _discontinuity_ 를 유발하게 된다.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_screenz1.png){: .center-image}
![Hashed Alpha Testing](/images/hat_codesnippet_lerpscale.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

그래서 위 코드와 같 _discretize_ 시킨 올림처리한 값과, 내림처리한 값을 사용한 두 _Hash_ 값 사이의 보간을 통해서 _Alpha Threshold_ 를 구해준다. 하지만 이 코드는 아직 문제점이 존재한다. 만약 _maxDeriv_ 의 값이 0 ~ 1 사이라면 내림값이 반드시 0이 되기 때문에 보간할 값 중 한개의 값이 고정되게 된다. 그래서 아래와 같은 코드를 사용한다.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_exp2.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

_pixScale_ 을 그냥 계산하는 대신, _discretize_ 된 두개의 스케일값을 2의 지수로 표현하여 값이 0으로 되는 것을 막는다. 이렇게 보간된 값을 사용하여 _Alpha Threshold_ 를 정해주면 약간의 문제가 생긴다. 보간을 함으로써 균일하지 않게 랜덤값이 분포되었기 때문이다. 그래서 아래와 같은 식을 사용하여 다시 값을 분포시켜준다.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_cdf.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

위의 식을 적용하면 모든 값들이 균일하게 분포되어 진정한 랜덤값의 _Alpha Threshold_ 가 생성된다고 한다. 아래는 전체 코드다.

<br/>
![Hashed Alpha Testing](/images/hat_codesnippet_whole.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf">Cwyman.org : Hashed Alpha Test(Extended)</a>
</center>
<br/>

자세한 사항은 논문에서 확인할 수 있다([[Cwyman17]](http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf)). 결과는 아래 유튜브 영상에서 확인할 수 있다.

{% youtube "https://www.youtube.com/watch?v=p4TYf5DDpbQ" %}

이를 통해 전보다 훨씬 나은 _Alpha Test_ 품질을 얻을 수 있게 되었다. 하지만 _Hashed Alpha Testing_ 의 결과는 _Stochastic Test_ 처럼 픽셀이 흩뿌려진 느낌을 지울 수 없다. 어느정도의 랜덤값에서 생성이되니 이는 어쩔 수 없는 결과다.

## Alpha Distribution

_Alpha Test_ 의 구린 품질을 좀 더 개선할 수 있는 방법이 또 있다. 이번년도 _I3D_ 에 제출된 _Alpha Distribution_ 이라는 논문이 있는데, 이는 _Hashed Alpha Testing_ 처럼 런타임에 계산을 하지않고 각 _Mip-level_ 의 텍스쳐를 미리 처리해놓는 방법 중에 하나다. 미리 계산된 _Texture_ 들을 사용하여 일반적인 _Alpha Test_ 를 그대로 사용하기만 하면 된다. 아직 직접 사용한 예시는 없어 검증되지는 않았지만, 이 방법이 그대로 사용될 수 있다면 _Alpha Test_ 부분에서는 거의 끝판왕이 될 것 같다.

_Alpha Distribution_ 일반적인 _Alpha Test_ 를 기준으로 _Alpha Threshold_ 가 고정되어 있다는 것을 가정한다. 그렇게 되면 _Alpha Threshold_ 에 따라서 픽셀에 출력이 되냐, 안되냐로  따질 수가 있다.(_Binary Visibility_) _Binary Visibility_ 를 각 _Mip-level_ 에 맞춰서 고르게 분산(_Distribution_)시키는게 _Alpha Distribution_ 의 목적이다.

_Alpha Distribution_ 은 두가지 분산방법을 사용한다. _Error Diffusion_ 과 _Alpha Pyramid_ 이라는 방법을 사용한다. 하나씩 알아보자.

_Error Diffusion_ 은 하나하나의 픽셀을 순회하면서, 각 픽셀의 _Binary Visibility_ 에 해당하는 값(0 아니면 1)과 이미지가 가지고 있는 _Alpha_ 값을 비교해 그 오차(_Quantization Error_)를 다른 픽셀에 나누어준다. _Binary Visibility_ 는 다음과 같이 정해진다.

> αˆi = αi >= ατ : 1, αi < ατ : 0

αi 는 이미지가 가지고 있는 이산화된 _Alpha_ 값이고, ατ 는 _Alpha Threshold_, 한계값을 뜻한다. αˆi 는 해당 픽셀의 _Binary Visibility_ 를 뜻한다. 이것을 가지고 _Quantization Error_ 를 계산한다.

> ϵi = αi − αˆi

ϵi 는 _Quantization Error_ 를 뜻하고 픽셀이 보이게 된다면 _~1 <= ϵi < 0_ 의 값을 가지게 되고 픽셀이 보이지 않는다면 _0 < ϵi <= 1_ 의 값을 가지게 된다. 이런 _Quantization Error_ 는 인근 픽셀로 분포된다. 아래 그림을 보자.

![Error Diffusion](/images/ad_error_diffusion.png){: .center-image}

그림에서 ϵi 가 들어가 있는 부분이 현재 처리중인 픽셀이며, ϵi 의 값은 인근 픽셀로 고정된 비율로 _Alpha_ 값에 더해진다. (x+1,y) 는 7/16, (x-1,y+1) 은 3/16, (x,y+1) 은 5/16, (x+1,y+1) 은 1/16 비율로 분포된다. 이런 방법으로 각 픽셀을 순회하면서 처리하면 _Error Diffusion_ 은 간단하게 끝난다. 오차 확산이라는 이름이 굉장히 직관적이다.

_Error Diffusion_ 은 픽셀과 픽셀사이의 _Alpha_ 값을 고르게 분포시킨다. 하지만 약간의 문제가 존재한다. 보이게 되던, 안보이게 되던 _Alpha_ 값이 0.3 ~ 0.7 정도로 중간값을 가지고 있다면, 한 픽셀은 강조되고, 옆의 픽셀은 보이지 않게 된다. 이러한 방법은 아래 이미지와 비슷한 결과를 만든다.

<br/>
![Michelangelo's_David_-_Floyd-Steinberg](/images/Michelangelo's_David_-_Floyd-Steinberg.png){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Dither">Wikipedia : Dither</a>
</center>
<br/>

_Error Diffusion_ 의 문제는 위 그림처럼 비슷한 색 영역에 있어도 분산된 영향을 받아서 각 픽셀이 부드럽게 보이지 않는 현상이 발생한다. 이러한 특징을 _Dithering_ 이라고 부른다. 그래서 이보다 나은 품질을 위해 _Alpha Pyramid_ 라는 다른 방법이 소개된다.


## 참조

 - [Anti-aliased Alpha Test: The Esoteric Alpha To Coverage](https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f)
 - [NVidia developer : Hashed Alpha Testing](https://developer.download.nvidia.com/assets/gameworks/downloads/regular/GDC17/RealTimeRenderingAdvances_HashedAlphaTesting_GDC2017_FINAL.pdf?pUIX8DXxfad7mL4zB3GOthX3r5IgGao9UWxYuYb3q9h10RXrQeYko-dEuJXJxt1hhsI9J_9KJDcCYGeWWksxlaHTrXSE825D_3izja7LUFOtzhaeBUqpn7qbwXaaGlLdbipjE3PeI3e2IMn45mQAA3OV2PD-kG2y9cecTaWE2uum2uwdHgyn0nhYiLOvlOsrUzewbK5REH7vAm3-lNWzxehw_5Tphg)
 - [Cwyman.org : Hashed Alpha Test(Extended)](http://cwyman.org/papers/tvcg17_hashedAlphaExtended.pdf)
 - [Cemyuksel : Alpha Distribution](http://www.cemyuksel.com/research/alphadistribution/)
