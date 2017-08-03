---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - skinning
  - vertex deformation
  - try
---

이전 [dual quaternion skinning]({{ site.baseurl }}{% post_url 2017-07-20-dual-quaternion-skinning %}) 글에서 _dual quaternion skinning_ 에 대해서 설명해 보았다. 이전 글에서는 단순히 _dual quaternion skinning_ 에 대해서 알아보고 장점에 대해서 알아보았다. 단점에 대해서는 언급을 하지않았는데 사실 단점도 존재하긴 한다. 새로 소개할 방법의 논문에서 _dual quaternion skinning_ 의 단점에 대해서 언급했다.

_joint bulging artifact_ 라고 하는 것인데, 90도 정도 휜 부분의 바깥쪽이 튀어나오는 현상을 말한다. 아래 그림에서 볼 수 있다.

![both bent](/images/dqs_ocor_bent.png){: .center-image}

왼쪽은 _dual quaternion skinning_ 을 표현한 그림이고, 오른쪽은 곧 소개할 _optimized center of rotation_ 방법이 적용된 스키닝이다. 각 그림의 오른쪽의 90도 휜 부분을 관찰하면 _dual quternion skinning_ 이 약간 아래가 부푼 모습을 볼 수 있다. 이를 _joint bulging artifact_ 라고 한다. 그리고 오른쪽 위의 확대된 그림을 보면 _dual quaternion skinning_ 은 약간 움푹 들어간 것을 볼 수 있다.

그래서 디즈니 리서치라는 연구소에서 새로운 방법을 2016 년 Siggraph 에서 소개했다. 논문의 이름은 _Real-time Skeletal Skinning with Optimized Centers of Rotation_ 이다.

<!-- more -->

이 방식은 간단한 아이디어로 접근하면서도 기존의 _Weight Blending_ 데이터와 호환되며, 런타임에서도 꽤나 쓸만한 방식이다. 또한 처리하는 데이터도 _linear bleding skinning_ 과 _dual quaternion skinning_ 에 비해서도 조금 늘었다.

_optimized center of rotation_ 의 기본적인 아이디어는 기존의 방식은 회전 축의 위치가 뼈의 가중치로 결정되어 문제가 생기는 것을 알아채서 각 정점별로 다른 회전의 위치(_center of rotation_)를 정해 주는 것이다. 앞에 붙은 _optimized_ 가 내포한 의미도 있다. 사실 모든 정점별로 _center of rotation_ 을 정해주면 굉장히 번거롭다. 또한 이 논문에서 소개하는 계산방식은 실시간으로 계산하기에는 너무 느리다. 그래서 이 논문에서는 각 정점별로 기본 포즈(보통 T 포즈를 뜻함.)를 기준으로 _center of rotatoin_ 을 미리 데이터를 계산해서 실시간으로는 데이터를 참조해서 _skinning_ 을 한다.

그런데 이 스키닝 방식을 구현하려면 먼저 _center of rotation_ 을 계산해주는 코드를 직접 짜야한다. 아직은 3D 에디팅 툴에서 지원을 하지 않기 때문이다. 게임 엔진들 또한 마찬가지다. 또한 일반적인 싱글 스레드 프로그램으로 짜기에는 너무 데이터가 많아서 여러 스레드를 이용하는 멀티 스레딩이나 GPGPU 기술을 사용해서 구현해야 한다. 필자는 구현의 편의성을 위해 멀티 스레딩을 사용했지만 조금 느렸다. 꽤나 괜찮은 GPU 를 가지고 있으면 GPGPU 를 사용하는것이 훨씬 빠를 것이다.

자세한 방법을 알고 싶으면 논문을 참고하라.([논문 링크](https://s3-us-west-1.amazonaws.com/disneyresearch/wp-content/uploads/20160705174939/Real-time-Skeletal-Skinning-with-Optimized-Centers-of-Rotation-Paper.pdf)) 논문에서 나오는 첫번째로 소개되는 정점과 정점간에 _similarity_ 를 계산하는 식과 _center of rotation_ 위치를 계산하는 네번째 식, 그 아래에 있는 Intergration 항목을 참조하면 _center of rotation_ 을 계산하는 코드를 짤 수 있다. _center of rotation_ 을 계산하는 방식의 아이디어는 꽤나 간단하다. _bone weight_ 들의 연관성(_similarity_) 를 계산해 이 숫자를 각 정점간의 가중치로 설정한다. 이 연관성(_similarity_)를 계산하기 위해서는 최소 두개의 같은 뼈의 가중치를 가지고 있어야 한다. 만약 아무것도 연관성이 없다면 _linear blending skinning_ 으로 계산하게 하면 된다. 그리고 각각 폴리곤의 세 정점의 평균 _similarity_ 와 폴리곤의 세 정점의 평균 위치, 그리고 삼각형의 넓이를 계산해서 _center of rotation_ 을 계산한다.

다만 논문의 처음에서는 모든 정점을 기준으로 전부 _similarity_ 를 계산하다는 늬앙스가 있었는데 그런식으로 계산하면 굉정히 오래걸린다고 논문에 쓰여져 있었다.(싱글 스레드 C++ 기준 30000 개의 정점을 가진 모델) 그래서 이 논문에서는 여러 방법을 제시했다. 가장 중점적인 것은 _bone weight_ 끼리의 거리를 직접 계산하여 _cluster_(집단)을 구성하여 _center of rotation_ 을 계산할 때 계산하는 절대적인 데이터를 줄이는 방법이다. 또한 일정 _similarity_ 보다 값이 적으면 탐색을 중단하는 방법도 제시했다. 그리고 마지막으로 제시한 방법은 위에서도 말한 병렬 프로그래밍을 이용하는 것이다.

직접 스키닝을 계산하는 방법도 간단하다. 회전 연산은 기존의 행렬로 계산하던 것을 사원수로 변환 후 회전 연사을 하는 사원수를 _blending_ 하면된다. 위치 이동 연산은 살짝 다른데, _linear blending skinning_ 에서 정점을 계산하는 식을 정점 대신 _center of rotation_ 으로 계산 후에 그 값에다가 _blending_ 된 사원수로 _center of rotation_ 값을 변환시켜 빼주면 위치 이동 값(translate)가 완성된다. 위치 이동 값(translate)는 정점을 회전 연산 후에 값을 더해주기만 하면 된다.

_optimized center of rotation_ 을 계산하는 코드와 해당 skinning 방법을 Unity 로 구현해 놓았다. [Github : CustomSkinningExample](https://github.com/hrmrzizon/CustomSkinningExample) 에서 확인할 수 있다. (_center of rotation_ 을 정확하게 논문에 나온대로 계산하는 코드를 짠것은 아닙니다. 그 부분은 이해 해주시고 참고해주길 바랍니다. 또한 자세한 방법을 아시는 분은 댓글 달아주시면 감사하겠습니다.)

## 참조

 - [Disney Reasearch : Real-time Skeletal Skinning with Optimized Centers of Rotation](https://www.disneyresearch.com/publication/skinning-with-optimized-cors/)
