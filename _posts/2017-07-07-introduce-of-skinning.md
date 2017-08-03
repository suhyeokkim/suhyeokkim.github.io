---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - skinning
  - vertex deformation
  - try
---

2달전 쯤에 스키닝에 대한 글을 본적이 있다. 그때는 스키닝이 뭔지도 정확히 모르던 시점이였다. Unity 에서는 LBS 라는 방법으로 스키닝을 지원하는데 이 방식보다 나은 방식이 있는데 어찌하여 옛날 방식을 지원하는지에 대한 불만글이였다. 그래서 공부할 것을 찾던 필자는 Unity 에서의 커스텀 스키닝을 구현을 목표로 잡았다. 정리를 위해 하나하나 글을 남겨보도록 하겠다. 이 글에서는 간단히 스키닝의 개념에 대해서 써보도록 하겠다. 이전에 쓴 [handling rig and skinning]({{ site.baseurl }}{% post_url 2017-05-19-handling-rig-and-skinning %}) 에서도 간략하게 다루었지만 기초 지식이 없는 상태에서 급하게 쓴 글이였고, 굉장히 Unity 스러운 글이기에 다시 처음부터 써보겠다.

<!-- more -->

일반적으로 3D 물체는 대부분 고정된 정점을 가지고 그대로 그려진다. 물체의 정점들이 한꺼번에 움직이는 방법은 흔하나 정점 하나하나 각자 움직이는 경우는 몇 없다. 모든 정점이 자기만의 기준을 가지고 움직이면 엄청난 계산량을 요구하기 때문이다. 하지만 게임을 만들려면 정점을 움직여서 표현하여 보다 실제적인 움직임을 연출할 수 있을 수도 있다. 극단적인 예를 들면 펄럭이는 옷가지라던가 부서지는 오브젝트가 있겠다. 하지만 방금전에 말한 두가지는 굉장히 극단적인 이야기이고 살아 움직이는 물체를 표현하기 위해 스키닝이라는 기술이 있다. 예를 들면 사람 혹은 동물이 있겠다.

스키닝이라는 말은 직역하면 _"피부를 입히다."_ 라는 뜻이다. 하지만 일반적인 3D 오브젝트는 정해진 정점들을 이어서 삼각형을 만들어 꽤 많은 갯수의 삼각형으로 외형을 표현한다. 이렇게 생각하면 바깥의 피부를 입힌다는 것은 조금 이해가 안될 것이다. 여태까지 엄청나게 많은 이론이 나왔지만 게임에서 쓰이는 3D 모델의 스키닝이라는 용어는 일반적으로 생각하는 뜻이 있다.

1. 정점의 집합으로 이루어진 3D 물체에서 특정한 위치를 가지고 있는 "뼈" 라는 개념이 있다.
2. "뼈" 는 일반적은 3D 오브젝트가 가질 수 있는 변환을 할 수 있다. (Translate, Rotation, Scale)
3. 각 정점들은 특정한 "뼈" 를 기준으로 잡아 기준이 되는 "뼈" 의 변환 정보를 각 정점에 적용시켜 뼈가 움직이면 정점도 같이 움직이게 된다.

위에서 설명한 세가지가 적용이 된것이 "스키닝" 이 적용된 3D 물체라고 할 수 있다. 이 간단한 개념이 확장되어 현 시대의 게임에서도 쓰이고 있다. 매우 간단한 이 방법은 약간의 문제가 있다. 관절같은 경우 두개이상의 "뼈" 변환을 참조해야 한다. 어떻게 두개 이상의 "뼈" 변환을 합칠 것인가? 이 문제는 아직까지도 완전히 해결되지 않았고 이 문제를 해결하기 위해 꽤 많은 논문들이 나왔다. 단순히 뼈를 이용하는 방식 뿐만아니라 다양한 방식으로도 말이다. 먼저 가장 널리 알려지고 가장 많이 쓰이는 방법에 대해서 알아보자.

_Linear Blend Skinning_ 이라는 방법이 있다. 이 방법은 굉~장히 단순하다. 그만큼 많이 쓰이는 듯 싶다. 논문이 1988년에 나온 기술로.. 조금만 잔머리 굴리면 쓸만한 내용이다. 두개 이상의 뼈의 변환 행렬을 정점 위치를 계산하여 정해진 가중치에 비례해서 값을 섞는다. 이 방식은 보통 값과 값사이의 특정한 위치를 가져올때 쓰이는 방법이다. 이 방식은 수학적으로 생각해보면 울퉁불퉁한 곡선에 해당되는게 아니라 선형적으로 값을 보간하는 방법이므로 _Linear Blend Skinning_ 이라고 불리는 것이다. Unity 의 스키닝된 메쉬를 그리는 _Skinned Mesh Renderer_ 컴포넌트가 아직도 LBS 를 사용하고 있다. 하지만 이 방법은 흔히 알려진 문제가 하나 있다. _'Candy Wrapper'_ - 한국어로 사탕 껍질 이라고 불리는 현상인데, 아래 그림의 사탕 껍질을 이야기 하는 것이다.

![사탕 껍질](/images/candy_wrapper.jpg){: .center-image}

주목할 것은 안의 사탕이 아니라 양 옆의 꼬여져서 엄청 가늘어진 상태의 껍질이다. LBS 를 사용하면 해당 오브젝트의 관절이 저렇게 표현될 수 있다. 해당 축으로 180도 돌리면 말이다. 아래 그림에 상세하게 나온다.

![](/images/umbra-ignite-2015-rulon-raymond-the-state-of-skinning-a-dive-into-modern-approaches-to-model-skinning-33-638.jpg){: .center-image}

하여튼 _Linear Based Blending_ 은 현 시대에서는 그다지 유용한 기술은 아니다. 하지만 많은 곳에서 채택되어 아직도 남아있다. 많은 사람들의 관심이 몰리는 분야는 아니기 때문에 기술 발전 자체는 그다지 빠른편이 아니다. 하지만 30년 전의 기술을 아직도 쓴다는건 그리 좋은 생각은 아닌 것 같다. 이를 위해 10년전에 괜찮은 수 체계를 도입했다. 이는 다음 글에서 설명하겠다. 다음 글 : [_dual quaternion skinning_]({{ site.baseurl }}{% post_url 2017-07-20-dual-quaternion-skinning %})


혹시 _Linear Blend Skinning_ 의 Unity 구현을 보고 싶으면 [GitHub : CustomSkinningExample](https://github.com/hrmrzizon/CustomSkinningExample) 에서 보면 된다.

## 참조

 - [RenderHell](https://simonschreibt.de/gat/renderhell-book1/)
 - [Paper : State of the Art in Skinning Techniques for Articulated Deformable Characters](http://www.fratarcangeli.net/wp-content/uploads/GRAPP.pdf)
