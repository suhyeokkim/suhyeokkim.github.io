---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - rendering
  - transparency
---

오래전부터 게임같은 실시간으로 안정적인 성능을 뽑아내야하는 컴퓨터 그래픽에서의 투명한 물체는 항상 골칫거리였다. "투명" 하다보니 일반적으로 사용되는 최적화 방법도 사용할 수 없기 때문에 퍼포먼스의 문제가 있으며, 일반적으로 지원하는 _Alpha Blending_ 을 사용할시에는 물체의 순서를 직접 소팅해주어야 했다. 투명한 물체를 그리는 일반적인 방법의 문제에 대해서 알아보고, 문제를 부분적으로 해결할 수 있는 몇가지 방법들을 적어보겠다.

<!-- more -->

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

_OIT_, 순서에 구애받지 않는 투명물체를 그리는 방법을 통칭하는 용어다. 대부분의 게임에서는 _OIT_ 를 사용하여 투명물체를 그린다. 많이 알려진 방식은 두가지가 있다. _Depth Peeling_ 과 _Weighted Blended OIT_ 다.

_Depth Peeling_ 은 _Detph_ 를 사용하여 카메라로부터 가장 가까운(_Depth_ 값이 가장 작은) 표면의 색을 누적시키는 _OIT_ 기법이다. 직역하자면 "_Depth_ 껍질 벗기기" 인데, 조금 더 자세히 알아보자.

<br/>
![OIT-Lab DepthPeeling](/images/OIT_Lab_DepthPeeling.gif){: .center-image}
<center>출처 : <a href="https://github.com/candycat1992/OIT_Lab">Github : candycat1992 / OIT_Lab</a>
</center>
<br/>

_Depth Peeling_ 은 총 3단계로 이루어진다. 맨 처음에는 _Alpha_ 값에 관계없이 _Depth Test_ 를 작거나 같은값에서 되게 해두고, _Depth Write_ 가 가능하게 해준다. 그리고 그려준다. 그렇게 되면 카메라에서 가장 가까운 표면들이 처음에 그려지게 되고, 해당 상태에서 그려진 표면의 _Depth_ 값들이 _Depth Buffer_ 에 저장된다. 즉 처음에 그려진 결과를 가진 색들의 집합과 _Detph_ 의 집합을 가지고 시작한다.

이제 비슷한 그리기를 계속 반복한다. 어떻게 반복하냐면, 두가지의 _Depth Test_ 를 사용해야 한다. 일단 처음과 같은 작거나 같은(_LessEqual_) _Depth Test_ 를 계속 해주고, 여기서 추가적으로 이전에 했던 _Depth Buffer_ 의 값을 가져와 출력되는 _Depth_ 값이 작거나 같을 때 픽셀의 결과를 누락시킨다.(_Discard_) 즉 이전에 출력한 표면을 _Depth Test_ 로 누락시키고 그 뒤에서 가장 _Depth_ 값이 작은 것들을 출력한다. 이때 _Depth_ 값은 계속 기록해야한다. 아래 그림을 보자.

<br/>
![Depth Peeling Cross-Section](/images/depthpeeling-crosssection.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/assets/gamedev/docs/OrderIndependentTransparency.pdf">NVidia : Order-Independent Transparency</a>
</center>
<br/>

맨 처음에 했던 결과가 _Layer 0_ 의 결과이고, 두번째 과정을 반복하면 뒷부분을 계속 출력하게 된다. 그래서 임의의 횟수만큼 이와 같은 과정을 계속 반복해준다. 그러면 두번쨰 과정, _Depth Peeling_ 은 끝이다.

다음은 임의의 횟수만큼 _Depth Peeling_ 을 해서 출력된 색의 결과와 _Depth Buffer_ 를 가지고 위에서 언급한 일반적인 _Alpha Blending_ 의 과정인 _"over"_ 연산을 해주면 된다. 순서는 가장 뒤에있는 결과, 마지막에 출력한 결과부터 처음 출력한 결과, 카메라에서 가장 가까운 결과까지 순서대로 _Layer_ 를 _"over"_ 연산을 통해 결합시켜주면 된다. 아래에는 _Layer_ 의 크기를 점점 증가시킨 결과를 애니메이션으로 보여주는 그림이다.

<br/>
![OIT-Lab DepthPeeling Anim](/images/depthpeeling.gif){: .center-image}
<center>출처 : <a href="https://github.com/candycat1992/OIT_Lab">Github : candycat1992 / OIT_Lab</a>
</center>
<br/>

다른 방법에 비해 _Depth Peeling_ 은 그다지 좋은 방법은 아니다. 들어가는 비용이 너무 크다. _Depth Peeling_ 은 _Layer_ 가 크면 클수록 더 많은 것들을 표현할 수가 있다. 하지만 _Layer_ 의 갯수에 맞춰서 들어가는 메모리가 굉장히 크다. 우선 화면 해상도를 기준으로 색과 _Depth_ 를 저장하는 버퍼를 여러개 만들어야 한다. 그리고 _Layer_ 의 갯수만큼 _Geometry Pass_(_Vertex Shader_, _Tesselation_, _Geometry Shader_)를 반복한다. 이는 정점 데이터가 많으면 많을수록 크리티컬하다. 이런 여러가지의 단점이 있기 때문에 _Depth Peeling_ 은 잘 쓰이지 않는것으로 보인다. 또한 _Shader_ 코드내에서 _Depth Test_ 를 해주게 되면 GPU 의 _Early-Z Test_ 가 비활성화가 되기 때문에 퍼포먼스 손실도 있을 것이라고 예측된다.

그래서 _Depth Peeling_ 보다는 나은 성능을 가진 _Weighted Blended OIT_ 라는 방법이 어느정도 쓰이는 것으로 보인다. _Weighted Blended OIT_ 는 2013년에 논문을 발표하였으며, 요즘에도 쓰이는 방법이다. GDC2018 에서 Agent of Mayhem 의 제작사가 _Weighted Blended OIT_ 에 대한 내용을 발표했다.([링크](https://www.dsvolition.com/publications/rendering-technology-in-agents-of-mayhem/)) _Weighted Blended OIT_ 는 2013년에 고안된 기법으로 _Depth Peeling_ 보다는 덜 오래된 방법이다. _Weighted Blended OIT_ 는 물체의 색을 표현할 떄, 특정한 가중치(_weight_)를 구해 곱해서 표현한다. 그리고 이전에 출력된 결과에 그대로 색값을 더해준다. 이제 자세한 방법에 대해서 알아보자.

<br/>
![wboit formula](/images/weightedblendedOIT_formula_.png){: .center-image}
<center>출처 : <a href="http://jcgt.org/published/0002/02/09/">jcgt : Weighted Blended Order-Independent Transparency</a>
</center>
<br/>

위 그림은 최종으로 나온 픽셀이 가지고 있는 색을 보여준다. _n_ 은 해당 픽셀에 그려지는 갯수이고, _α_ 는 _Alpha_, _C_ 는 _Color_, _Z_ 는 _Depth_, _C0_ 는 투명 오브젝트를 그리기 전에 그려진 불투명한 표면의 색이다. 식만 봐서는 자세히는 모르기 때문에 아래 그림을 보면서 알아보자.

<br/>
![wboit formula](/images/weightedblendedOIT_formula_explain_.png){: .center-image}
<center>출처 : <a href="http://jcgt.org/published/0002/02/09/">jcgt : Weighted Blended Order-Independent Transparency</a>
</center>
<br/>

일단 총 3가지 단계로 나뉜다. _RGB * Weight_, _Alpha * Weight_ 를 _RGBA_ 로 저장해주는 누적값(_accumulate_)을 하나의 렌더 타겟에 저장하고, 얼마나 픽셀의 색이 덮는지에 대한 여부가 아닌, 반대로 이전의 색이 얼마만큼 노출이 될 수 있는지에 대한 노출값(_revealage_)을 다른 하나의 렌더 타겟에 저장한다. 그 다음 그 결과를 가지고 위의 식의 값을 계산한 결과가 _Weighted, Blended OIT_ 의 끝이다. 다만 _accumulate_ 와 _revealage_ 값들은 _MRT_ 를 통해서 _DrawCall_ 을 단축시킬 수 있을 것 같다.

_Weight_ 값을 계산하는 방법은 여러가지가 있다. 가장 중요한 것은 _Weight_ 를 계산할 떄, _Depth_, _Alpha_ 이 두가지를 사용하여 계산하는 것이 가장 중요한 점이다. _Depth_ 는 카메라를 기준으로 앞 뒤를 판별하는 중요한 기준이며, _Alpha_ 값은 투명한 정도를 나타내는 중요한 값이다. _weight_ 를 구하는 공식은 아래 그림을 참고하자.

<br/>
![wboit formula](/images/weightedblendedOIT_weight_formula_.png){: .center-image}
<center>출처 : <a href="http://jcgt.org/published/0002/02/09/">jcgt : Weighted Blended Order-Independent Transparency</a>
</center>
<br/>

_0.1 ≤ |z| ≤ 500_ 를 가정하고 만든 식이다. 이중에 _d(z)_ 라는 식이 있는데 이는 아래를 보면된다.

<br/>
![wboit formula](/images/weightedblendedOIT_weight_formula_additional_.png){: .center-image}
<center>출처 : <a href="http://jcgt.org/published/0002/02/09/">jcgt : Weighted Blended Order-Independent Transparency</a>
</center>
<br/>

이는 _GLSL_ 기준으로, _HLSL_ 에서 취급하는 _Depth_ 의 범위가 달라지면 바뀔수도 있다. 식을 선택할 떄 중요한 점은 커브가 어떤식으로 생성되는지 보아야 한다. 아래 그림을 보자.

<br/>
![wboit formula](/images/weightedblendedOIT_weight_curve_.png){: .center-image}
<center>출처 : <a href="http://jcgt.org/published/0002/02/09/">jcgt : Weighted Blended Order-Independent Transparency</a>
</center>
<br/>

논문에 실려있던 그림이며, 각 식에 따른 _weight_ 의 커브를 잘 보여준다. 어느 정도 지식이 있다면 보여주고 싶은 컨텐츠의 특성에 따라서 식을 변형을 할 수도 있겠다.

_WBOIT_ 의 장점은 굉장히 전통적인 방법으로 구현이 가능하기 때문에 어떠한 기계에도 사용할 수 있다는 장점이 있다. _Depth Peeling_ 은 _MRT_ 를 사용해서 해야하므로 _DX10+_ 를 지원하는 디바이스부터 가능한 것에 비하면 굉장한 장점이다. _Occlusion Culling_ 은 안되지만 거의 _O(n)_ 의 속도와 많아봐야 2개의 해상도에 비례하는(_RGBA_, _R_) 메모리만 있으면 되기 때문에 투명 물체를 엄청나게 많이 출력하지 않는다면 일반적으로 쓸 수 있다.

_WBOIT_ 또한 단점이 몇가지 존재한다. 첫번째로 불투명한 물체와 함께 _"over"_ 연산을 한다면 앞의 물체에 의해 가려지게 된다. 하지만 _WBOIT_ 는 물체가 다른색을 표현할 경우에는 불투명한 물체를 표현하지 못한다. 그리고 _Depth_ 값의 정밀도에 따라서 표현할 수 있는 투명한 물체의 사이의 거리가 달라진다. 아무리 식을 변형시킨다고 하더라도 부동소수점 정밀도의 문제가 생길수가 있다. 마지막으로 모든 오브젝트가 카메라의 _Z_ 축을 따라서 움직인다면 출력값은 달라질 것이다. 이는 _weight_ 계산에 _Depth_ 값이 들어가서 이러한 결과를 보여주는데, 해당 논문에는 그다지 신경쓰지 않았다고 적혀있다.

하지만 위의 단점은 충분히 안고갈만한 단점이기 때문에 투명한 물체를 그릴 때는 _Weighted Blended OIT_ 가 가장 나은 방법이라고 본다. 아래 _Alpha Blend, Detph Peeling, _Weighted Blended OIT_ 이 세가지 방법에 대한 비교 영상이 있다.

![]("https://www.youtube.com/watch?v=JVa9xXddgbM")

위에서 언급한 [Rendering Technology in 'Agents of Mayhem'](https://www.dsvolition.com/publications/rendering-technology-in-agents-of-mayhem/) PT 에서는 기존의 _WBOIT_ 에서 _Emmisive_ 한 물체를 위해 추가적인 화면 해상도에 비례하는 버퍼를 사용하여 빛나는 투명 물체를 표현하는 방법을 서술해놓았다. 또한 해당 논문의 저자가 1년전에 고안한 [_Phenomenological Transparency_](https://www.youtube.com/watch?v=jWe5Ae22Ffs&t=555s) 라는 방법도 있다.

## 참조

 - [cwyman.org : "Exploring and Expanding the Continuum of OIT Algorithms," HPG 2016.](http://cwyman.org/papers.html)
 - [NVidia : Order-Independent Transparency](http://developer.download.nvidia.com/assets/gamedev/docs/OrderIndependentTransparency.pdf)
 - [NVidia : Order Independent Transparency with Dual Depth Peeling](http://developer.download.nvidia.com/SDK/10.5/opengl/src/dual_depth_peeling/doc/DualDepthPeeling.pdf)
 - [jcgt : Weighted Blended Order-Independent Transparency](http://jcgt.org/published/0002/02/09/)
 - [Implementing Weighted, Blended Order-Independent Transparency](http://casual-effects.blogspot.com/2015/03/implemented-weighted-blended-order.html)
 - [Github : candycat1992 / OIT_Lab](https://github.com/candycat1992/OIT_Lab)
 - [GDC2018 : Rendering Technology in 'Agents of Mayhem'](https://www.dsvolition.com/publications/rendering-technology-in-agents-of-mayhem/)
 - [Youtube : Phenomenological Transparency](https://www.youtube.com/watch?v=jWe5Ae22Ffs&t=555s)
