---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - color
  - colorimetry
---

HDR 에 대한 내용들을 찾다보면 _color space_ 에 대한 개념을 기본적으로 알고 있어야 수학적인 내용을 배울 때 단계적으로 학습해야 하는 것처럼 대부분의 내용들을 쉽게 이해할 수 있다. 필자의 경우 이에 대한 학습이 전혀 없었고, 직접 자료를 찾아보기 전까지 무슨 소리인지 전혀 몰랐던 상태였다. 다행히 여러 분야에 걸쳐 꽤 많이 알려진 지식들이고 받아들이기에 어려운 개념은 아니라서 이에 대해 글을 쓰면서 정리해보려 한다.

<!-- more -->

일반적으로 컴퓨터에서 색을 나타내기 위해서 RGB 튜플을 사용한다. YMCK 같은 프린트를 위한 방법도 존재하지만 빛을 이용한 색을 나타내는 방법은 거의 RGB로 빛을 나타내는 방식을 쓰는 것으로 보인다. 이는 사람의 눈에서 빛을 색으로 감지하는 감각기관인 _cone cell_ 이 총 3가지의 파장 분포 가진 타입을 가진 즉 3가지의 파장 분포를 인식하는 _cone cell_ 이 존재한다. 아래 그림에서 나온 L, M, S 파장 분포가 _cone cell_ 이 인식하는 파장이다. 보통은 _l-cones_, _m-cones_, _s-cones_ 라고 하는 듯 하다.

<br/>
![Wikipedia : CIE 1931 color space](https://upload.wikimedia.org/wikipedia/commons/1/1e/Cones_SMJ2_E.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/CIE_1931_color_space">Wikipedia : CIE 1931 color space
</a>
<br/>
</center>
<br/>

보면 쉽게 알 수 있겠지만, L은 빨간색, M은 초록색, S는 파란색으로 나타내져 있다. 이렇게 표현된 이유는 아래 그림을 보면 알 수 있다.

<br/>
![Wikipedia : Visible spectrum](https://upload.wikimedia.org/wikipedia/commons/c/c4/Rendered_Spectrum.png){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Visible_spectrum">Wikipedia : Visible spectrum
</a>
<br/>
</center>
<br/>

가장 높은 경우를 가진, 분포에서 가장 높은 반응을 가지는 포인트를 각 색으로 나타낸 것이다. 즉 빛으로 색을나타낼 떄 RGB로 나타내는 이유 중 하나는 "_LMS cone cell_ 이 반응하는 가장 큰 경우가 각각 Red,Green,Blue 이기 때문이다." 라고도 말할 수 있겠다.

그렇다면 우리는 색을 RGB 튜플로 나타내니, 이에 대한 정의가 있을 것이라 생각할 수 있다. 그리고 이러한 정의가 존재한다. _color space_ 가 무엇이냐? 라고 묻는다면 단순히 색을 정의한 공간이라고 밖에 설명할 수 밖에 없다. 좀 더 목적에 치중하면, 색을 정량화 하기 위해서 정의한 것이다. 정도에 머무를 것이다. 이에 대한 정의를 먼저 알아야 대강의 이해가 될것이다. 아주 기본적인 _color space_ 에 대한 정의인 두가지, _CIE 1931 RGB color space_, _CIE 1931 XYZ color space_ 가 있다. 사실상 가장 많이 활용되는 _color space_ 는 _CIE 1931 XYZ color space_ 이다. 하지만 우선 _CIE 1931 RGB color space_ 먼저 알아보자. 이 부분이 먼저 시작되는 부분이기 때문이다.

_CIE 1931 RGB color space_ 의 정의에 대해서 언급해보자면, 특정 실험을 통해서 $$ \bar{r}(\lambda),\bar{g}(\lambda),\bar{b}(\lambda) $$ 함수를 정의한다. 이 실험은 사람을 대상으로 해당 특정 파장의 색을 보여주고 r,g,b 값을 조절하여 색을 실험자가 직접 맞추는 실험이라고 한다. 자세한 내용은 [링크](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_RGB_color_space)에 나와있다. 정의된 파장에 대한 함수가 아래에 나와있다.

<br/>
![Wikipedia : CIE 1931 color space](https://upload.wikimedia.org/wikipedia/commons/6/69/CIE1931_RGBCMF.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/CIE_1931_color_space">Wikipedia : CIE 1931 color space
</a>
<br/>
</center>
<br/>

이렇게 정의된 함수를 _color matching function_ 이라 하는데, _color matching function_ 를 사용해 우리가 실질적으로 사용하는 RGB 값을 정의할 수 있다. 단 여기에 같이 사용되는 또 다른 측정값들이 있는데, _spectrum power distribution_ 이라는 것이다. 이는 해당 방정식에서 $$ S(\lambda) $$ 로 표현된다. 이를 간단하게 말하자면 물체가 반사하는 파장의 분포다.

$$
R = \int_0^\infty \bar{r}(\lambda) d\lambda,\;
G = \int_0^\infty \bar{g}(\lambda) d\lambda,\;
B = \int_0^\infty \bar{b}(\lambda) d\lambda $$

위와같이 정의가 가능하며, 해당 값은 절대적인 값들이기 때문에 보통은 이들을 합해 정규화한 값을 쓴다.

$$ r = R/(R+G+B),\; g = G/(R+G+B),\; b = B/(R+G+B)  $$

정의에 대한 부분은 이해를 못하더라도 상관없다. 그저 우리가 아는 RGB 표현 방식이 있고, 이를 수학적으로, 명시적으로 정의한게 _CIE 1931 RGB color space_ 이라고 생각하면된다. 다음은 _CIE 1931 XYZ color space_ 인데, 위에서 정의한 방법: _color matching function_ 과 _spectrum power distribution_ 을 _convolution_ 하여 정의된다. 다만 실험을 통한 _color matching function_ 의 정의는 다르다. 실험을 통한 $$ \bar{x}(\lambda),\bar{y}(\lambda),\bar{z}(\lambda)  $$ 는 다음과 같다.

<br/>
![Wikipedia : CIE 1931 color space](https://upload.wikimedia.org/wikipedia/commons/8/8f/CIE_1931_XYZ_Color_Matching_Functions.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/CIE_1931_color_space">Wikipedia : CIE 1931 color space
</a>
<br/>
</center>
<br/>

이렇게 정의된 _color matching function_ 과 _spectrum power distribution_ 을 사용하여 다음과 같이 _CIE 1931 XYZ color space_ 의 값들을 나타낼 수 있다.

$$ X = \int_0^\infty \bar{x}(\lambda) d\lambda,\; Y = \int_0^\infty \bar{y}(\lambda) d\lambda,\; Z = \int_0^\infty \bar{z}(\lambda) d\lambda $$

$$ x = X/(X+Y+Z),\; y = Y/(X+Y+Z),\; z = Z/(X+Y+Z)  $$

위의 _CIE 1931 RGB color space_ 와 굉장히 비슷하게 정의했지만 _CIE 1931 XYZ color space_ 는 그리 단순하게 설계되진 않았다. 총 5가지의 특징을 가지고 있다. 이는 다음과 같다.

1. _CIE 1931 RGB color space_ 와 확실하게 다른점으로 _color matching function_ 이 음수를 가지지 않는다. 즉 무조건 양수라는 이야기다.
2. $$\bar{y}(\lambda)$$ _color matching function_ 은 해당 _spectrum power distribution_ 의 _luminance_ 를 추출해내는 _photopic luminous efficiency function_ 함수다. 즉 간단하게 말하자면 Y 값이 _luminance_ 라는 말이다.
3. $$ x=y=z=1/3 $$ 인 지점에서 _white point_ 가 존재해야 한다고 한다.
4. _CIE xy chromaticity diagram_ 에서 _color gamut_ 보았을 때, 1사분면, 즉 _x,y_ 값이 무조건 양수인 상태에서 존재해야 한다고 한다.
5. $$ \bar{z}(\lambda) $$ 의 값이 650 nm 이상에서는 전부 0으로 세팅된다고 한다. 이는 아마도 실험 측정값의 에러를 잘라내기 위한 것인듯 싶다.

4번의 정의에서 _CIE 1931 XYZ color space_ 자체는 색의 음수영역까지 포함하는 _imagenary color space_ 인걸 알 수 있다. 이는 _CIE 1931 XYZ color space_ 가 광범위한 _color space_ 인것을 알 수 있다.

이렇게 정의된 _CIE 1931 XYZ color space_ 의 쓰임새는 굉장히 다양하다. 우선 위와같은 사항을 고려해서 설계된것이 아마도 가장 큰게 아닐까 싶다. 많은 _color space_ 들이 _luminance_ 와 _chromaticity_ 를 구분해서 정의하는데, _CIE 1931 XYZ color space_ 는 이미 구분이 되어있기 때문에 여기에서 조금 더 변형을 가해서 원하는 성질을 추가하면 되기 때문이라고 고려된다. 즉 다양한 쓰임새는 _CIE 1931 XYZ color space_ 자체가 잘 정의되어 있기 때문이라고 고려된다. _CIE 1931 XYZ color space_ 는 _CIE 1931 RGB color space_ 로부터 선형변환할 수 있도록 되어있다. 물론 반대의 경우도 가능하다.

$$
\begin{bmatrix}
X\\
Y\\
Z\\
\end{bmatrix} =
\cfrac{1}{0.17697}
\begin{bmatrix}
0.49000&0.31000&0.20000\\
0.17697&0.81240&0.01063\\
0.00000&0.01000&0.99000\\
\end{bmatrix}
\begin{bmatrix}
R\\
G\\
B\\
\end{bmatrix}
$$


$$
\begin{bmatrix}
R\\
G\\
B\\
\end{bmatrix}  =
\begin{bmatrix}
0.41847&-0.15866&-0.082835\\
-0.091169&0.25243&0.015708\\
0.00092090&-0.0025498&0.17860\\
\end{bmatrix}
\begin{bmatrix}
X\\
Y\\
Z\\
\end{bmatrix}
$$

이제 자주 보이는 _CIE xy chromaticity diagram_ 이라는 것이 있다. 앞에서 정의된 _x,y_ 값을 사용하여 나타낸다. _z_ 값은 $$ 1-x-y $$ 로 쉽게 계산이 가능해서 단순하게 _x,y_ 값을 사용하여 나타낸다. 이는 _X,Y,Z_ 의 값의 비율로 계산되는 값으로 절대적인 수치와는 상관없이 그저 _chromaticity_ 만을 나타내기 위한 방법이다.

_chromaticity_ 와 _luminance_ 에 대한 설명을 명확하게 하자면, _luminance_ 는 빛 자체의 밝기, 광도라고 말할 수 있겠다. 검은색에서 흰색의 차이는 단지 밝기의 정도만 차이나는 것이다. _chromaticity_ 는 밝기에 상관없이 보여지는 색 자체가 다른 것을 뜻한다. 예를들어 어두운 파란색과 어두운 빨간색은 비슷한 _luminance_ 를 가질 수 있지만, _chromaticity_ 는 전혀 다르다고 말할 수 있다. 아래 다이어그램은 _chromaticity diagram_ 이기 때문에 밝기에 대한 정보는 없고 단지 색의 차이, 색차만 나와있는 것을 알 수 있다.

<br/>
![Wikipedia : CIE 1931 color space](https://upload.wikimedia.org/wikipedia/commons/3/3b/CIE1931xy_blank.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/CIE_1931_color_space">Wikipedia : CIE 1931 color space
</a>
<br/>
</center>
<br/>

_CIE xy chromaticity diagram_ 에서 밑의 직선을 제외한 말발굽 모양의 숫자가 표시된 부분을 _spetral locus_ 라고 부르는데, 이는 파장의 길이에 따라 달라지는 가시광선을 나타낸다. 곡선에 표시된 숫자는 파장의 크기를 나타낸다. 아래 직선은 _line of purple_ 이라고 하는데, 여기서 재미있는 것은 _spectral locus_ 와 _white point_ 사이에 있는, 즉 환경에 정해진 흰색 사이에 있는 색은 얼마든지 하나의 파장을 가진 빛으로 나타낼 수 있고, 그게 아닌 _line of purple_ 과 _white point_ 사이에 있는 색은 하나의 파장을 가진 빛으로 나타낼 수 없다.

위에서도 언급했지만 _CIE XYZ_ 는 다른 _color space_ 와 변환으로 연결되어있는 이론상으로 기본적인 _color space_ 이다. _CIE XYZ_ 에서 파생된 여러가지 _color space_ 들이 존재하는데 몇가지만 살펴보겠다. 첫번째는 _CIE LAB_ 이라는 _color space_ 인데 이는 사람이 인지할 수 있는 색의 변화에 맞게 개선되었으며, 프린터가 주로 사용하는 _CMYK Color Model_, 디스플레이에서 주로 사용되는 _RGB Color Model_ 둘다 포함한다고 한다. 두번째는 _CIE LUV_ 로, 주로 빛으로 색을 나타내는 컴퓨터 그래픽에서 사용되고, 이 또한 _perceptual uniformity_ 를 개선하였다고 한다. 이 외에도 꽤 많은 _color space_ 들이 존재한다.

다음은 _color gamut_ 혹은 _gamut_ 이 무엇인지, 어떤 것들이 있는지에 대해서 써보겠다. 위키의 정의에 따르면, _gamut_ 은 _color space_ 의 _complete subset_ 이라고 한마디로 쓰여있다. _complete subset_ 인 이유는 잘 모르겠으나 아마도 추상적이지 않고 특정한 값을 정의함으로써의 _complete subset_, 완벽한 부분집합이라고 말한것으로 생각된다. _gamut_ 이라는 용어는 이글에서의 의미와도 같고, 거의 대부분 특정한 주어진 환경, 특정한 출력 장치에서 구현될 수 있는 색 공간에서의 부분집합을 뜻하는 말로 쓰이나, 가끔 어떤 이미지, 영상에서 추출된 색의 완벽한 집합을 의미하는 말로도 쓰인다고도 한다.

[UHD Color for Games](https://developer.nvidia.com/sites/default/files/akamai/gameworks/hdr/UHDColorForGames.pdf)에서는 _gamut_ 이 정의되기 위해서는 색의 기준이되는 여러개의 색 공간의 점들, 복수개의 _color primary_(_RGB Model_ 인 경우 3개), 주로 특정 환경에서의 명시적인 흰색을 나타내기 위해 색 공간에서의 특정한 점으로 정의되는 _white point_, 특정 색 공간에서 해당 _gamut_ 으로 변환 하기 위한 _encoding function_ 이 필요하다고 쓰여있다. 이 글에서 언급하는 _gamut_ 들은 전부 디스플레이에서 사용되는 _gamut_ 들이기 때문에, 적어도 여기서 언급되는 _gamut_ 들은 _RGB_ 로 표현이 되기 때문에 _r,g,b_ 를 나타내는 _color primary_ 를 사용한다.

_gamut_ 은 디스플레이의 색 표준이기 때문에 사용되는 몇가지의 _gamut_ 들이 존재한다. 그 중 예전부터 가장 많이 알려지고 사용된 _sRGB_ 에 대해서 먼저 언급하자면, 이는 CRT 모니터의 _gamut_ 으로 사용될 정도로 꽤 오래된 _gamut_ 이다. 현재 사용되는 _gamut_ 중에 표현할 수 있는 색의 범위가 가장 적다. _sRGB_ 의 최소한의 필요한 빛의 밝기, _minimum luminance_ 는 80nit 이다. _white point_ 는 _D65_ 로 거의 표준적으로 사용된다. 최근 사용되는 _SDR_ 모니터들의 최대 _luminance_ 가 200~300nit 가 되기 때문에 꽤 차이가 난다고 할 수 있다. 아래 그림인 _chromaticity diagram_ 을 보면 쉽게 알 수 있다.

<br/>
![Color gamut Rec.2020, DCIP3, Rec.709](http://www.lamptolaser.com/images/spectrum.jpg){: .center-image}
<center>출처 : <a href="http://www.lamptolaser.com/fact7.html">www.lamptolaser.com : The FACTS OF LIGHT, FACT 07
</a>
<br/>
</center>
<br/>

_sRGB_ 의 _encoding_ 은 아래와 같다. _CIE XYZ_ 을 변환시키려면 아래와 같이 _linear RGB_ 값으로 변환시킨 다음에, 해당 값을 꽤나 알려진 _gamma correction_ 이라는 과정, _gamma function_ 에 _linear RGB_ 값을 넣어 _sRGB_ 값을 얻을 수 있다.

$$
\begin{bmatrix}
\mathit{R}_{linear} \\ \mathit{G}_{linear} \\ \mathit{B}_{linear} \\
\end{bmatrix} =
\begin{bmatrix}
3.2406&-1.5372&-0.4986 \\ -0.9689&1.8758&0.0415 \\ 0.0557&-0.2040&1.0570 \\
\end{bmatrix}
\begin{bmatrix}
\mathit{X}_{D65} \\ \mathit{Y}_{D65}\\ \mathit{Z}_{D65}\\
\end{bmatrix}
$$

$$ \gamma(\mathit{u}_{rgb}) = \begin{cases} 12.92\mathit{u}_{rgb}&\mathit{u}_{rgb} \leq 0.0031308\\ (1.055\mathit{u}_{rgb}^{1/2.4}-0.055&otherwise \end{cases}\\ $$

역변환과 여러 정보에 대해서는 [Wikipedia : sRGB](https://en.wikipedia.org/wiki/SRGB)에서 확인할 수 있다.

_sRGB_ 와 거의 비슷하게 쓰이는 _ITU-R Recommendation BT.709_, 보통 줄여서 _Rec.709_, _BT.709_ 라고 불리는 _gamut_ 은 HDTV 의 기준으로 많이 쓰이는 _gamut_ 이다. _sRGB_ 와 확실하게 다른점은 _encoding function_ 이 다르다는 점이다. 이는 _viewing environtment_, 디스플레이가 사용되는 환경이 다르기 때문이라고 한다.

위의 _chromaticity diagram_ 에서 두번째로 넓은 영역을 차지하는 _DCI-P3_ 은 _Digital Cinema Initiative_ 라는 조직에서 만들고, _Society of Motion Picutre & Telelvision Engineers_ 라는 조직에서 _publishing_ 한 _gamut_ 으로, 꽤 많은 디스플레이들이 지원하는 비교적 넓은, _HDR_ 과 같이 응용될 수 있는 _gamut_ 이다. 가장 넓은 영역을 차지하는 _Rec. 2020_, _ITU-R Recommendation BT.2020_ 은 비교적 최근에 고안된 _gamut_ 으로, 적어도 _HDMI 2.1_, _HDR_ 이 가능한 환경에서 사용될 수 있기 때문에 가장 한정적으로 사용될 수 밖에 없는 _gamut_ 이다.

주로 사용되는 _gamut_ 에 대해 알아보았으니 나머지 연산에 대해서 한번 알아보자. _gamut_ 은 색을 연산하기 위해서는 반드시 고정되어야 한다. 아래 그림을 보면 같은 색이라도 어떤 _color space_, _gamut_ 이냐에 따라서 같은 연산의 결과라도 _gamut_ 에 따라서 달라진다.

<br/>
![color operation in gamut](/images/color_op_in_gamuts.PNG){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/hdr-gdc-2018">HDR Ecosystem for Games, Evan Hart, 2018
</a>
<br/>
</center>
<br/>

그래서 _sRGB_ 같은 작은 _gamut_ 을 사용하는 경우에 _HDR_ 을 활용하기 위해 _gamut_ 을 강제로 늘리고 싶은 경우가 있는데 _gamut mapping_ 이라고 불리고 그다지 추천되는 방법은 아니다. 디지털 상에서라면 이미 _quantization_ 이 되어있기도 하고, 색의 범위가 줄어들어 단순히 _color gamut_ 을 _clipping_ 하게 되면 _chromaticity_ 가 급격하게 변경되고, 마찬가지고 색의 범위가 늘어나서 단순히 _stretching_ 하는 경우에도 전의 경우와 같다. 이는 아트팀에서 노발대발할 부분이므로 최대한 하지 않는 것을 추천하는 경우가 많다. 여러 자료에서는 그래서 그냥 _sRGB_ 를 쓰라고 언급한다.


<!--
$$ \gamma^{-1}(\mathit{u}_{rgb}) = \begin{cases} \mathit{u}_{rgb}/12.92&\mathit{u}_{rgb} \leq 0.04045\\ (\frac{\mathit{u}_{rgb}+0.055}{1.055})^{2.4}&otherwise \end{cases}\\ $$
$$
\begin{bmatrix}
\mathit{X}_{D65} \\ \mathit{Y}_{D65}\\ \mathit{Z}_{D65}\\
\end{bmatrix} =
\begin{bmatrix}
0.4124&0.3576&0.1805 \\ 0.2126&0.7152&0.0722 \\ 0.0193&0.1192&0.9504 \\
\end{bmatrix}
\begin{bmatrix}
\mathit{R}_{linear} \\ \mathit{G}_{linear} \\ \mathit{B}_{linear} \\
\end{bmatrix}
$$
-->

<!-- ITP(ICtCp) : Hdr, 부록 정도로 -->


## 참조

 - [Wikipedia : Color space](https://en.wikipedia.org/wiki/Color_space)
 - [Wikipedia : Gamut](https://en.wikipedia.org/wiki/Gamut)
 - [Wikipedia : sRGB](https://en.wikipedia.org/wiki/SRGB)
 - Real-Time Rendering 4th, Tomas Akenine-Möller et all, 2018
 - [특집 예술세계에서의 물리학 : 색채과학이란 - 디지털 색채를 중심으로, 곽영신.우정원, 2000](http://webzine.kps.or.kr/contents/data/webzine/webzine/15124615671.pdf)
 - [UHD Color for Games, Evan Hart, 2016](https://developer.nvidia.com/sites/default/files/akamai/gameworks/hdr/UHDColorForGames.pdf)
 - [HDR Ecosystem for Games, Evan Hart, 2018](https://developer.nvidia.com/hdr-gdc-2018)
