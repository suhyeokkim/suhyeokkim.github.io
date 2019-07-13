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
4. _color gamut_ 이 _chromaticity diagram_ 으로 보았을 때, 1사분면, 즉 _x,y_ 값이 무조건 양수인 상태에서 존재해야 한다고 한다.
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

위에서도 언급했지만 _CIE XYZ_ 는 다른 _color space_ 와 변환으로 연결되어있는 이론상으로 기본적인 _color space_ 이다. _CIE XYZ_ 에서 파생된 몇가지 _color space_ 들에 대해서도 한번 알아보자. 우선 우리가 _color space_ 에 대해서 찾아보면 가장 많이 보이는 그림이 있다.

<br/>
![Wikipedia : CIE 1931 color space](https://upload.wikimedia.org/wikipedia/commons/5/5f/CIE-1931_diagram_in_LAB_space.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/CIE_1931_color_space">Wikipedia : CIE 1931 color space
</a>
<br/>
</center>
<br/>


_CIE XYZ_ 이외에도 여러가지의 _color space_ 들이 존재한다. _CIELAB_, _CIELUV_ 등이 존재하는데, 이들은 기존의 _CIE XYZ_

CIELAB was designed so that the same amount of numerical change in these values corresponds to roughly the same amount of visually perceived change.
With respect to a given white point, the CIELAB model is device-independent—it defines colors independently of how they are created or displayed. The CIELAB color space is typically used when graphics for print have to be converted from RGB to CMYK, as the CIELAB gamut includes both the gamuts of the RGB and CMYK color models.

CIELUV
It is extensively used for applications such as computer graphics which deal with colored lights. Although additive mixtures of different colored lights will fall on a line in CIELUV's uniform chromaticity diagram (dubbed the CIE 1976 UCS), such additive mixtures will not, contrary to popular belief, fall along a line in the CIELUV color space unless the mixtures are constant in lightness.


<!--
chromaticity diagram: plane of color spcae

gamut or color gamut: subset of color space
  Rec. ITU-R BT.709
  sRGB,scRGB
  DCI-P3
  Rec. ITU-R BT.2020
  Rec. ITU-R BT.2100
-->

<!--
hdr 표준 : 안해도 될듯
SMPTE st-2084
SMPTE st-2094
-->


<!--
  color space 의 종합적인 사용 용도
 -->





## 참조

 - [Wikipedia : Color space](https://en.wikipedia.org/wiki/Color_space)
 - Real-Time Rendering 4th, Tomas Akenine-Möller et all, 2018
 - [특집 예술세계에서의 물리학 : 색채과학이란 - 디지털 색채를 중심으로, 곽영신.우정원, 2000](http://webzine.kps.or.kr/contents/data/webzine/webzine/15124615671.pdf)
 - [UHD Color for Games, Evan Hart, 2016](https://developer.nvidia.com/sites/default/files/akamai/gameworks/hdr/UHDColorForGames.pdf)
