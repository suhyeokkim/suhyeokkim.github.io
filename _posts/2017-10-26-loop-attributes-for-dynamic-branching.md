---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - hlsl
---

_Programmable Shader_ 를 작성할 때에는 한가지 유의해야 할 점이 있다. 이는 _Dynamic Branching_ 이라는 개념이다. _Dynamic Branching_ 은 조건 분기문이 _Programmable Shader_ 에서 사용될 때 나타나는 현상을 말한다. _Programmable Shader_ 는 직렬이 아닌 병렬로 실행되기 때문에 나타나는 특성이다. 반복문에서도 조건 분기를 사용한다. 간단한 아래 코드를 보자.

``` hlsl
int i = 0;
while(i < 5)
{
  i++;
}
```

위 코드는 프로그래밍을 입문할때 볼 수 있는 코드다. 중요한 것은 _while_ 단어가 있는 줄에 있는 조건 식이다. _(i < 5)_ 조건식 때문에 _Dynamic Branching_ 이 발생한다. 이 _Dynamic Branching_ 을 명시적으로 없에거나 만들기 위해 _hlsl_ 에서 _attribute_ 를 지원한다. 아래를 보자.

``` hlsl
[Attribute] for ( Initializer; Conditional; Iterator )
{
  Statement Block;
}
```

해당 구문은 [MSDN : for Statement](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509602.aspx) 에서 가져왔다. 일반적으로 프로그래머이 정말 많이본 _for_ 반복문이다. 우리가 봐야할 것은 _for_ 구문 왼쪽의 _\[Attribute\]_ 라는 구문이다. 이 부분에는 총 4가지의 옵션을 넣을 수 있는데, 이 글에서 언급할 _\[Attribute\]_ 는 두가지다. _unroll_ 과 _loop_ 이 두가지이다.

_hlsl_ 로 정상적인 반복문 실행을 하게되면, 매번 반복을 할때 마다 조건식을 검사하게 되고, 해당 반복문의 범위를 마음대로 조정하여 코딩을 할 수 있다. 다만 조건식의 범위가 매번 달라진다면 _Dynamic Branching_ 이 발생하게 된다. 그리고 반복문이 매번 _Programmable Shader_ 가 실행될 때 상수로 반복을 한다면 쉐이더 컴파일러는 최적화를 위해 특정한 행동을 하게 된다. 아래 코드를 보자.

``` hlsl
for(int i = 0; i < 5; i++)
{
}
```

위의 코드는 루프를 다섯번 실행시키는 코드다. 따로 안에 인덱스 _i_ 를 건드리지 않는다면 쉐이더 컴파일러는 컴파일 시점에 최적화를 한다. 이를 _unroll_ 이라고 부를 수 있는데, 실행할 반복문을 반복문으로 해석하는게 아닌 5번 연속해서 같은 행동을 하게 하는 것이다. 조건 자체도 없어지고 그저 인덱스를 풀어쓰게 된다. 이는 상수(constant)로 반복문을 제어하면 쉐이더 컴파일러가 알아서 해주기 때문에 신경써주지 않아도 된다. 다만 _unroll_ 이라는 키워드를 써서 바뀔 때는 변수를 사용해 반복문을 제어할 때다. 변수를 사용하면 컴파일 시점에서는 추측할 수 없기 때문에 암시적으로 _unroll_ 을 할 수 없다. 이 때 _unroll_ 키워드를 사용하여 제어할 수 있다.

``` hlsl
int count = ...;
[unroll(5)]
for(int i = 0; i < count; i++)
{
}
```

또한 암시적으로 _unroll_ 된 반복문을 명시적으로 반복문으로 실행되게 할 수도 있다.

``` hlsl
[loop]
for(int i = 0; i < 5; i++)
{
}
```

# 참조 자료

 - [MSDN : for Statement](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509602.aspx)
 - [GameDev : Can someone explain \[loop\] and \[unroll\] to me?](https://www.gamedev.net/forums/topic/649408-can-someone-explain-loop-and-unroll-to-me/)
 - [GameDev : HLSL warning: Gradient-based operations must be moved out of flow control to prevent
 ](https://www.gamedev.net/forums/topic/543541-hlsl-warning-gradient-based-operations-must-be-moved-out-of-flow-control-to-prevent/)
