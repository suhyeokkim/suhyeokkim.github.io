---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - skinning
  - vertex deformation
  - try
---

이전 [Introduce of skinning]({{ site.baseurl }}{% post_url 2017-07-07-introduce-of-skinning %}) 글에서 Skinning 에 대한 설명과 LBS 에 관한 내용을 간단하게 다루어 보았다. 하지만 글 마지막에 해결되지 않은 문제가 하나 있었다. _Linear Blend Skinning_ 의 _"Candy Wrapper"_ 라는 현상이였는데, 이 글에서는 그 문제를 위해 2008년에 고안된 방법에 대해서 알아볼 것이다.

<!-- more -->

_Linear Blend Skinning_ 은 정점을 변환시키기 위해 행렬을 사용한다. 위치나 벡터를 1x4, 4x1 행렬로 취급해 행렬곱으로 계산해 위치값을 변환시킨다. 즉 한개의 값을 이용해서 변환을 한다. 조금 불편한 점은 변환 행렬을 _Weight Blending_ 하기가 어렵다.(필자의 경우 행렬을 Blending 하는데 실패했습니다. 아마 행렬 데이터 정규화가 안되서 그런것 같습니다. [링크](https://github.com/hrmrzizon/CustomSkinningExample/issues/6)에 증상이 있으니, 혹여나 방법을 아신다면 댓글 부탁드립니다.) 그래서 각 뼈를 기준으로 변환된 위치를 뼈의 가중치로 평균값을 내서 최종 변환된 정점을 구한다.

행렬을 사용한 변환의 장점은 위치 변환(translate), 회전 변환(rotation), 크기 변환(scaling)을 포함한 세가지 변환들을 전부 합쳐서 정보를 가지고 있을 수 있다. 물론 분리해서도 가능하다. 단점은 행렬 곱을 아는 사람은 알겠지만 절대적인 곱셈, 덧셈의 량이 꽤 된다. 3개의 변환을 합친 변환 행렬은 일반적으로 4x4 행렬을 사용하고 아무리 최적화를 해도 4x3 행렬을 사용하는게 전부다. 가장 중요한 단점은 _Linear_ 하게 위치를 _Blending_ 시키니 전글에서도 언급한 _"Candy Wrapper"_ 현상을 뽑을 수 있겠다.

그래서 [Ladislav Kavan](https://www.cs.utah.edu/~ladislav/) 이라는 사람이 꽤나 많은 연구를 통해 다양한 논문을 내었는데 그 중 주목할 것은 _dual quaternion skinning_ 이다. 필자는 이 정보를 처음 접했을 때 조금 이해가 안되는 부분이 많이 있었다. 계산 방식 등 꽤나 이상한게 많았는데 _dual quaternion_ 이라는 개념이 우리가 알고 있는 일반적인 대수적인 개념에서 확장된 개념이였다. 게임 프로그래머라면 많이 들어봤을 법한 사원수(quaternion)과 _dual number_ 라는 이름만 들어도 생소한 개념의 단위를 합친 개념이다. 이를 수학적으로 알아보기 쉽게 자세히 설명하기엔 필자의 지식 수준이 매우 짧기에 정말 간단하게 설명하겠다.

_dual number_ 라는건 두개의 숫자를 하나의 단위로 본다. 또한 여러 연산이 가능하도록 정의되어 있다. _dual quaternion_ 은 사원수를 두개 가진 하나의 단위이다. 기본적으로 _dual number_ 의 연산을 따르지만 사원수(quaternion)의 개념에 의해 조금 바뀌는 부분이 꽤 있다. _dual_ 이니 두개의 개념이 있는데, 첫번째 개념은 _real_ 이라고 부른다. 두번째 개념은 _dual_ 이라고 부른다.

_dual quaternion_ 은 변환을 위해 사용될 수 있고 우리가 사용할 목적과도 같다. 일반적으로 행렬은 위치, 회전, 크기 변환에 쓰인다고 했다. _dual quaternion_ 은 일반적으로 위치, 회전 변환을 포함하고 있다. 또한 크기 변환도 가능하긴 하다. 일단은 크기 변환은 넘어가도록 하겠다. 그러면 우리가 볼것은 위치, 회전 변환인데 두개의 사원수에 회전 변환과 위치 변환이 각각 나뉘어져 들어간다. 첫번째 _real_ 에 회전변환이 들어가고, 두번째 _dual_ 에 위치변환이 들어간다. 그렇게 _dual quaternion_ 이 구성된다. 또한 각자 _dual quaternion_ 과 _Weight blending_ 도 정상적으로 되고(_quaternion_ 자체가 _blending_ 이 가능하기 때문이다.) _dual quaternion_ 끼리 합칠 수도 있고, 정점 변환도 가능하다. 그래서 이 _dual quaternion_ 을 _matrix_ 변환과 치환해서 사용이 가능하다.

또한 앞에서 강조한 _"Candy Wrapper"_ 현상도 어느정도 극복할 수 있다. 그냥 일반적으로 생각해 보았을 때 변환된 정점의 가중치를 곱해 평균값을 구한 것과는 다르게 변환 자체를 전부 합쳐서 한번의 변환으로 변환된 정점을 얻는 것은 조금 다르다고 생각된다. 필자는 Unity 를 사용하여 _dual quaternion skinning_ 을 구현했다. [Github : CustomSkinningExample](https://github.com/hrmrzizon/CustomSkinningExample) 에서 확인할 수 있다.

간단하게 _"Candy Wrapper"_ 현상을 해결하기 위해선 이 _dual quaternion skinning_ 을 사용하면 된다. 하지만 필자는 약 10년전의 기술보다 더 나은 기술이 있을거라 생각해 여러가지 찾아보았다. 그 중 게임에서 쓸 수 있는 스키닝 기법을 하나 발견했다. 그 방법은 다음 글에서 확인해보자. [다음 글]({{ site.baseurl }}{% post_url 2017-07-22-optimized-center-of-rotation %})

## 참조

 - [RenderHell](https://simonschreibt.de/gat/renderhell-book1/)
 - [Paper : State of the Art in Skinning Techniques for Articulated Deformable Characters](http://www.fratarcangeli.net/wp-content/uploads/GRAPP.pdf)
 - [EuclideanSpace : dual quaternion](http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/other/dualQuaternion/)
 - [Skinning.org](http://skinning.org/)
