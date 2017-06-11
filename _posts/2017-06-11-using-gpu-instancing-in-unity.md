---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - rendering
  - try
---


[Using Texture2DArray in Unity]({{ site.baseurl }}{% post_url 2017-06-04-using-texture2darray-in-unity %}) 에 이어 _DrawCall_ 을 줄이기 위한 방법에 대해서 소개하려한다. GPU Instancing 이라는 방법인데 _TextureArray_ 와 같이 응용해서 사용하면 획기적으로 _DrawCall_ 을 줄일 수 있다.   

일반적으로 알려진 _GPU Instancing_ 에 대해서 말하자면 컴퓨터의 RAM 에만 저장하던 데이터들을 GPU 메모리에 복사해놓고 GPGPU 나 쉐이더를 실행할 때 빠르게 데이터에 접근하는 것을 GPU Instancing 이라 한다. 만약 _GPU Instancing_ 을 사용하지 않으면 매번 _DrawCall_ 에 데이터를 넣어줘야하기 때문에 수많은 _DrawCall_ 이 걸리게 되고 이는 CPU 의 시간을 뺏어먹게 되어 영 좋지 않은 일이 된다. 보통은 같은 동작을 하는 오브젝트들을 최적화할 때 쓰인다. 사용하게 되면 _DrawCall_ 이 _O(__오브젝트 갯수__)_ 로 되던것이 O(1) 의 갯수로 줄어든다. 그래서 _TextureArray_ 와 같이 사용하게 되면 _DrawCall_ 이 _O(__오브젝트 갯수__ * __텍스쳐 갯수__)_ 로 계산되던게 _O(__1__)_ 로 바뀌어 버리니 CPU 시간을 엄청나게 많이벌 수 있다. 다만 GPU 메모리를 많이 잡아먹기 때문에 신경써서 데이터를 구성하지 않으면 무슨일이 일어날지 모른다.

<!-- more -->

기술을 써보기 전에 우선 구현 사항부터 생각해야 한다. 필자는 Unity 에서 지원하는 __SkinnedMeshRenderer__ 가 _DrawCall_ 배칭을 해주지 않아 간단한 스키닝을 직접 구현하였다. __SkinnedMeshRenderer__ 가 많은 기능을 지원하긴 하지만 __SkinnedMeshRenderer__ 컴포넌트의 갯수가 절대적으로 많아지고 매터리얼이 늘어나게 되면 어쩔 수 없이 원하는 기능을 붙여 직접 구현해야 한다. [InstancedSkinning](git@github.com:hrmrzizon/InstancedSkinningExmaple.git)에서 참고할 수 있다.

해야할 것은 두가지다. 쉐이더에서 데이터를 선언 후 직접 사용하는 코드를 짜주어야 하고, 스크립트에서는 필요한 데이터를 모아서 넣어주기만 하면 된다. 말로는 간단하지만 신경써주어야 할것이 많다. 필자 역시 간단하다고 생각하여 시작했으나 꽤 많은 삽질 끝에 성공했다.



## 참조

 - [Slideshare : Approach Zero Driver Overhead](https://www.slideshare.net/CassEveritt/approaching-zero-driver-overhead)
 - [Unity Manual : GPU Instancing](https://docs.unity3d.com/Manual/GPUInstancing.html)
