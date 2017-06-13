---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - try
---

Unity 에서 일반적으로 쓰이는 __SkinnedMeshRenderer__ 에서 지원하는 스키닝은 _linear blend skinning_ 이다. 간단한 게임을 만드는 사람들이나 단순한 케릭터를 만드는 사람들은 크게 문제를 느끼지 못한다. 하지만 이 방식은 적어도 두개의 뼈를 기준으로 스키닝 하기 시작하면 문제가 발생하기 시작한다. 일반적으로 통칭하는 이름은 _"Candy Wrapper"_ 이다. 아래 많이 쓰이는 그림을 보자.

<!-- more -->

![Candy Wrapper](https://www.cs.utah.edu/~ladislav/dq/lbsExample.png){: .center-image}

팔 부분이 꼬여버린 것이 굉장히 거슬린다. _linear blend skinning_ 방식을 쓰면 두 개의 뼈가 영향을 주는 정점에서 한개의 뼈만 180도 돌아갔을 때 이런식으로 사탕 껍질처럼 꼬인여서 _"Candy Wrapper"_ 라고 한것이다. 이 문제를 해결하기 위해 다른 여러가지 방법이 고안되었는데 그 방법들 중 끝판왕으로 인정된 기술은 글 제목에 쓰여져 있는 _dual quaternion skinning_ 이다.

_dual quaternion skinning_ 은 2006년 정도부터 연구되어 왔으며 2008년에 최종으로 논문이 발표된 기술이다. [Utah university : Skinning with Dual Quaternions](https://www.cs.utah.edu/~ladislav/dq/index.html) 에서 해당 자료들을 받을 수 있다.


## 참조

 - [Utah university : Skinning with Dual Quaternions](https://www.cs.utah.edu/~ladislav/dq/index.html)
 - [Wikipedia : Dual Quaternion](https://en.wikipedia.org/wiki/Dual_quaternion)
 - [NVidia Developer : QuaternionSkining](http://developer.download.nvidia.com/SDK/10.5/direct3d/screenshots/samples/QuaternionSkinning.html)
 - [NVidia Developer : Direct3D SDK 10 Samples](http://developer.download.nvidia.com/SDK/10.5/direct3d/samples.html)
 - [University of Texas at Austin : Linear Blend Skinning](https://www.cs.utexas.edu/~theshark/courses/cs354/assignments/assignment_5.shtml)
