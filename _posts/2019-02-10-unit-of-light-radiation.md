---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - terminology
---

real-time rendering 분야에서 PBR 이 정착하게 되면서, 빛에 대한 측정 기준을 알아야 되게 되었다. 단순하지만 확실하게 정의해놓지 않으면 헷갈리는 개념이기 때문에 정리 해보려 한다.

<!-- more -->

측정에 대한 이야기를 하기 전에, 알기쉽게 빛이 어떻게 행동하는지 설명하자면, 빛은 에너지가 없어질때까지 튕겨다닌다. 빛은 어떤 매체에 부딫힐 때, 해당 매체에 흡수될 수도 있고, 매체 안에 들어가서 들어간 곳과는 다른 위치에서 나올 수도 있고, 매체를 투과할 수도 있고, 매체에 닿았을 때 튕겨나올 수도 있다. 그렇게 에너지가 없어질 떄 까지 튕겨다닌다.

<br/>
![light properties](/images/light_properties.png){: .center-image}
<center>출처 : <a href="https://www.google.com/url?sa=i&source=images&cd=&cad=rja&uact=8&ved=2ahUKEwj-_K3V6PHgAhXHxbwKHQEuD7QQjhx6BAgBEAM&url=https%3A%2F%2Fwww.renishaw.com%2Fen%2Fa-basic-overview-of-raman-spectroscopy--25805&psig=AOvVaw138lccVwHl19r0jVfWMOpu&ust=1552109516453916">renishaw : A basic overview of Raman spectroscopy</a>
</center>
<br/>

빛의 세기를 정량적으로 이야기 할 때, 이를 빛의 복사량(radiation)이라고 한다. 이를 이야기 할때, 보통 두가지의 분류를 나누어 구분한다. 하나는 우리가 볼 수 있는 가시광선(대략 400nm ~ 700nm 사이의 파장(wavelength)을 가진 전자기파)과 파장에 관련없이 모든 전자기파를 기준으로 하는 것으로 나뉜다. 모든 전자기파의 세기를 측정하는 것을 _Radiometry_, 가시광선의 세기만 측정하는 것을 _Photometry_ 라고 한다. 일반적으로 눈에 보이는 것들을 신경써야 할때는 _Photometry_ 를 사용한다. 빛의 파장에 관계없이 계산된 복사량은 및의 커브와 같이 곱하여 적분하여 계산하면 photometric unit 으로 변환될 수 있다.

<br/>

$$ \int_{380}^{720} r(\lambda)c_p(\lambda) d\lambda $$

<p align="center">radiometric unit to photometric unit formula</p>
<br/>

<br/>
![light properties](/images/CIE_photometric_curve.png){: .center-image}
<center>출처 : <a href="https://www.researchgate.net/figure/CIE-photometric-curve_fig1_2711215">ResearchGate : CIE photometric curve</a>
<br/>
</center>
<br/>

위의 식은 파장에 따른 빛의 복사량의 distribution function : r(λ), 위의 그림의 커브를 나타낸 함수 c_p(λ) 로 빛의 복사량을 photometric unit 으로 변환하는 식을 나타낸 것이다. 범위는 대략적인 것이다.

아래 표는 radiometry, photometry 의 단위들을 비교한 표다.

|  | symbol | name in radiometry | unit of radiometry | name in photometry | unit of photometry |
|:----------|:------:|:------:|:-------:||:------:|:-------:|
| energy | Q | radiant energy  | joule(J) | luminous energy | talbot(T)=lumen second(lm⋅s) |
| e/time | φ | radiant flux | watt(W)=(J/sec) | luminous flux | lumen(lm)=(T/s) |
| e/t/area | E | irradiance | watt/area(W/m^2) | illuminance | lumen/area(lm/m^2)=lux(lux) |
| e/t/steradian | L | radiance intensity | watt/steradian(W/sr) | luminous intensity | lumen/steradian(lm/sr)=candela(cd) |
| e/t/a/sr | I | radiance | watt/area/sr(W/m^2/sr) | luminance | candela/area(cd/m^2)=nit(nit) |

<br/>
<p align="center">Radiometry, Photometry 비교 표(area 의 단위는 m^2 을 사용)</p>
<br/>

위 표를 잘 살펴보면 총 4종류의 기준이 나온다. 첫번째로는 순수하게 에너지의 수량이다. 표의 첫번째 행에 나온다. 두번째는 시간인데, 일반적으로는 초를 단위로 사용하며 속도를 나타내기 위해 사용된다. 이 에너지의 속도로 대부분의 중요한 개념들이 표현된다. 세번째로는 단위 면적이다. 이는 빛 에너지를 받는 표면을 기준으로 한다. Area 의 앞글자를 따서 수식에서는 A 로 표현한다. 마지막으로 입체각(solid angle)이 존재한다. 수식에서는 Ω 로 표현한다. (보통 radian 은 학생때 부터 많이 보지만 solid angle 은 생소할 가능성이 높다. 이 블로그에도 [solid angle 에 대해 설명한 글]({{ site.baseurl }}{% post_url 2019-03-08-steradian-and-solid-angle %})이 있다.)

첫번째 행과 두번째 행의 개념은 표만 보기만 해도 쉽게 알 수 있다. 에너지의 수량과, 에너지의 속도다. radiant flux 의 정의는 다음과 같이 나타낼 수 있다.

<br/>

$$ φ = \frac{\partial Q}{\partial t} $$

<p align="center">definition of radiant flux</p>
<br/>

이제 radiant flux 는 남은 세가지 정의에서도 계속 등장한다. 남은 factor 는 area 와 solid angle 인데, 먼저 area 가 들어간 세번째 행의 e/t/area 부터 보자. 여기서 area 는 어떤 표면의 넓이를 뜻하는데, 일반적으로 빛을 받는 표면의 넓이를 뜻한다. 정의는 다음과 같다.

<br/>

$$ E = \frac{\partial φ}{\partial A} $$

<p align="center">definition of irradiance</p>
<br/>

이 시점에서 처음에 언급한 빛이 엄청나게 튕긴다는 사실을 다시한번 생각해보자. 그렇다면 거의 모든 방향에서 빛이 들어온다고해도 무방하다. 아래 그림을 보면서 생각해보자.

<br/>
![irradiance](/images/irradiance2.png){: .center-image}
<p align="center">Siggraph 2011 : "Physically-based Lighting in Call Of Duty : Black Ops"</p>
<br/>

빨간 점은 빛을 받는 표면의 위치인데 표면의 넓이가 거의 0에 가까우니 점으로 표현되었다.(∂A) 그리고 주황색으로 표시된 화살표는 모든 방향에서 빛이 들어온다는 것을 표현하기 위한 것이다. 저 화살표가 빛을 나타내는 것이라면 화살표들이 반구를 따라서 무한히 많다고 생각할 수도 있다.

사실 위의 그림은 irradiance 와 radiance 가 같이 그림으로 나와있는 그림이다. 원래 슬라이드는 다음과 같다.

<br/>
![irradiance and radiance](/images/irradiance_and_radiance.png){: .center-image}
<p align="center">Siggraph 2011 : "Physically-based Lighting in Call Of Duty : Black Ops"</p>
<br/>

irradiance 는 반구를 따라 무한히 많은 화살표들이 해당 위치로 들어오는 빛의 복사량을 나타내고, radiance 는 그 중 하나의 화살표를 하나 집은것과 같다. 위에서 입체각에 대해서 언급했는데, radiance 의 유도된 식은 irradiance 의 식에서 입체각에 대해서 미분한것과 같다.

<br/>

$$ L = \frac{\partial^2 φ}{\partial A \partial Ω} $$

<p align="center">definition of radiance</p>
<br/>

radiance 는 순수하게 ray 하나의 개념이기 때문에 꽤 많은곳에서 단위로 사용할 수 있다. 가장 대표적인 일례는 _pixel shader_ 에서 빛과 재질에 따른 컬러값을 계산한 결과가 _radiance_ 다.
<!-- radiance 에 대한 설명? -->

마지막으로 radiance intensity 라는 개념이 있는데, 이는 radiant flux 를 입체각에 대해서 미분한 값이다.

<br/>

$$ I = \frac{\partial φ}{\partial Ω} $$

<p align="center">definition of radiant intensity</p>
<br/>

이는 입체각에만 신경쓰기 때문에 면적이 존재하지 않는 spot light 나 point light 의 세기를 나타내는데 쓰일 수 있다.

단순하게 각 단위와 개념들에 대해서 적어보았다. PBR 에서 응용되는 빛의 단위에 대한 자세한 설명은 Siggraph 2014 : "MovingFrostbite to Physically Based Rendering 2.0" 코스 노트에서 볼 수 있다.

## 참조

 - Light Measurement Handbook, Alex Ryer, 1997
 - Real-Time Rendering 4th, Tomas Akenine-Möller et all, 2018
 - [Wikipedia : Radiometry](https://en.wikipedia.org/wiki/Radiometry)
 - [Wikipedia : Photometry](https://en.wikipedia.org/wiki/Photometry)
 - Siggraph 2014 : "MovingFrostbite to Physically Based Rendering 2.0"
