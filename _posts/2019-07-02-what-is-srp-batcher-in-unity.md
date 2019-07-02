---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - srp_batcher
---

Unity의 SRP 의 개발과 같이 여러 기능들이 생겨나는 것 같다. 아마도 기존의 Unity 의 렌더링 모듈들을 최대한 개선하려는 시도로 보인다. 이번 년초에 공개된 _SRP Batcher_ 또한 효율을 개선하기 위한 것으로 보인다.

종종 보이는 용어 _batch_ 라는 용어는 "한꺼번에 처리한다." 라는 뜻으로 보통 쓰인다. 일반적인 렌더링 시스템에서의 _batch_ 는 최소한의 drawcall-driver overhead- 을 위해 렌더링할 것들의 데이터들을 최대한 묶어주는 시스템의 기능을 말하기 위해 사용되는 것 같다. 그리고 Unity 또한 기존의 _built-in batcher_ 시스템이 존재한다. 근데 이에 성능을 향상시키기 위해 _SRP batcher_ 라는게 만들어 졌다고 한다. 이는 곧 기존의 _built-in batcher_ 시스템에 비효율적인 부분이 존재한다는 것을 알 수 있다.

Unity를 사용을 하다보면 알 수 있지만, MeshRenderer 컴포넌트의 같은 쉐이더에 다른 파라미터를 가진 Material 을 추가하거나 바꾸게 되면 DrawCall 이 바꾼 Material 의 갯수에 비례해서 올라가는 것을 알 수 있다. 문제는 이게 _static batch_ 든 _dynamic batch_ 든 무조건 일어난다는 것에 문제가 있다. directX 에 직접 맞닿아본 적은 없지만 Unity로 Shader Model 5.0 부터 접한 필자로써는 이해가 잘 되지 않는 상황이였다.

문제는 Unity Blog의 해당 포스팅을 보면 알 수 있지만([링크](https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/)), Unity 자체가 dx9 레벨을 지원하면서 만들어졌으며, 여러 API(dx11)를 지원하려 하다보니 해당 API의 특징을 잘 사용하지 못한채 _built-in batcher_ 가 만들어진 듯 했다. 아래에는 _built-in batcher_ 시스템을 나타낸 그림이다.

<br/>
![built-in batcher](https://blogs.unity3d.com/wp-content/uploads/2019/02/SRP-Batcher-OFF.png){: .center-image}
<center>출처 : <a href="https://solitaryroad.com/c1003.html">Unity Blog : SRP Batcher: Speed up your rendering!
</a>
<br/>
</center>
<br/>

위와 같은 시스템이라면, 무조건 메터리얼이 바뀌면 이들의 정보를 갱신하기 위해 전체를 다 처리하는 코드로 되어있는 듯 하다. 하지만 여기서 조금 더 생각해보면, _Material_ 과 각 오브젝트들의 _Transformation_ 정보들은 다른 정보라고 할 수 있다. 그렇다면 이들을 한꺼번에 처리하는게 아니라, _Material_, _Transformation_ 정보를 나누어서 갱신하면 _Material_ 을 바꿀 때, 쉐이더 코드가 바뀌지 않는다면, _DrawCall_ 이 늘어나지 않도록 할 수 있겠다. 문서에는 다른 _Material_ 이지만 _Shader_ 의 갯수가 많지 않은 경우를 타겟으로 했다고 쓰여져 있다. 아래 그림은 _SRP Batcher_ 시스템을 나타내었다.

<br/>
![SRP batcher](https://blogs.unity3d.com/wp-content/uploads/2019/02/image5-3.png){: .center-image}
<center>출처 : <a href="https://solitaryroad.com/c1003.html">Unity Blog : SRP Batcher: Speed up your rendering!
</a>
<br/>
</center>
<br/>

위에서 언급한 데이터를 나눈 것과 동시에 중요한 것이 하나 더 있는데, 기존의 _Material_ 데이터를 계속 갱신해 주어야 했는데, _SRP Batcher_ 시스템은 데이터의 영속성을 보장한다고 한다. _Material_ 의 데이터를 나누어서 관리하기 때문에 각 오브젝트 당으로 _cbuffer_ 를 데이터를 가질 수 있다고 한다. _built-in batcher_ 시스템에서는 이와 같은 처리를 하기위해 쉐이더 레벨에서 인스턴싱이라는 것을 지원했었는데 SRP 에서는 몇 안되는 Uber 쉐이더를 사용한다고 가정하고, 이를 자동으로 처리해주는 듯 싶다.

<br/>
![SRP batcher](https://blogs.unity3d.com/wp-content/uploads/2019/02/image3-5.png){: .center-image}
<center>출처 : <a href="https://solitaryroad.com/c1003.html">Unity Blog : SRP Batcher: Speed up your rendering!
</a>
<br/>
</center>
<br/>

위 그림은 _batch_ 처리시 어떤 기준에 따라서 한꺼번에 처리하는지에 대해 알 수 있는 다이어그램이다.

## 참조

 - [Unity Blog : SRP Batcher: Speed up your rendering!](https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/)
