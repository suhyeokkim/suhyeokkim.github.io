---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - rendering
  - transparency
---

오래전부터 게임같은 실시간으로 안정적인 성능을 뽑아내야하는 컴퓨터 그래픽에서의 투명한 물체는 항상 골칫거리였다. "투명" 하다보니 일반적으로 사용되는 최적화 방법도 사용할 수 없기 때문에 퍼포먼스의 문제가 있으며, 일반적으로 지원하는 _Alpha Blending_ 을 사용할시에는 물체의 순서를 직접 소팅해주어야 했다. 투명한 물체를 그리는 일반적인 방법의 문제에 대해서 알아보고, 문제를 부분적으로 해결할 수 있는 몇가지 방법들을 적어보겠다.

일반적으로 아무런 방법없이 투명한 그리는 방법은 뒤에있는 물체부터 순서대로 그리는 것이다. 이를 형상화 시키면 아래 그림과 같다.

![over operator](/images/over_operator_draw_order.png){: .center-image}

그림에서는 아래부터 위쪽에 있는 문체를 순서대로 그린다. 파란색, 빨간색, 연두색 기준으로 그리게 된다. 그렇게 되면 이전에 그려진 결과와 오브젝트의 결과가 합쳐져서 표현되게 된다. 이는 다음과 같은 식으로 표현된다.

<br/>
![over-operator polynomial](/images/over-operator_polynomial.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/supplement/oitContinuum/2016_HPG_ExpandingOITContinuum.pdf">"Exploring and Expanding the Continuum of OIT Algorithms," HPG 2016.</a>
</center>
<br/>

_a0,c0_ 는 픽셀에서 출력될 _Alpha_ 와 _Color_ 를 의미한다. 그 뒤의 항에서 _a1,c1_ 은 이전에 그려진 결과를 뜻한다. 이런 방식을 _"over"_ 연산이라고 말한다. 이런 방식은 나중에 그려진 색이 조금 더 강조되고, 이전에 그려지는 색의 존재가 조금씩 흐려지는 것을 알 수 있다.

이 방법의 문제는 그려지는 순서를 직접 맞춰줘야 하는 것이다. 이는 굉장히 짜증나는 문제로, 단순한 정렬만으로는 세세한 부분의 문제를 해결할 수 없다. 아래 그림은 해당 문제를 잘 나타내어 준다.

<br/>
![Lumberyard : OIT example animation](/images/shared-OIT-example-animation_lumberyard.gif){: .center-image}
<center>출처 : <a href="https://docs.aws.amazon.com/ko_kr/lumberyard/latest/userguide/graphics-rendering-order-independent-transparency.html">lumberyard : OIT(Order Independent Transparency)</a>
</center>
<br/>

상단 두개의 그림이 일반적인 _"over"_ 연산을 한 방법이다. 정렬되지 않아 미리 정해진 순서대로 출력되며 물체가 회전하면 공간상의 순서가 바뀌므로 상단 두개의 그림같이 출력된다. 그래서 이런 _Depth_ 의 정렬 문제 때문에 만들어진 용어가 있다.

## Order Independent Transparency(OIT)

_OIT_, 순서에 구애받지 않는 투명물체를 그리는 방법을 통칭하는 용어다. 대부분의 게임에서는 _OIT_ 를 사용하여 투명물체를 그린다. 많이 알려지고 쓰이는 방식은 두가지가 있다. _Depth Peeling_ 과 _Weighted Blended OIT_ 다.

<!--
  일반적인 Alpha Blending
  Depth Peeling
  Weight blended OIT(I3D, Meyhem GDC PT)
-->

## 참조

 - [cwyman.org : "Exploring and Expanding the Continuum of OIT Algorithms," HPG 2016.](http://cwyman.org/papers.html)
 - [NVidia : Order-Independent Transparency Order-Independent Transparency](http://developer.download.nvidia.com/assets/gamedev/docs/OrderIndependentTransparency.pdf)
 - [jcgt : Weighted Blended Order-Independent Transparency](http://jcgt.org/published/0002/02/09/)
 - [Github : candycat1992 / OIT_Lab](https://github.com/candycat1992/OIT_Lab)
