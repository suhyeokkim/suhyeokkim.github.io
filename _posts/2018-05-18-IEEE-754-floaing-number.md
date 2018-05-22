---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - math
  - floating_point
---

코딩을 하던 도중, 비트로 나타내어진 2 byte floating number(half-precision) 데이터를 일반적인 4byte floating number(single-precision) 으로 나타내야 할 일이 있었다. 그래서 귀찮아서 알아보지 않았던 컴퓨터의 소수를 표현하는 방법에 대해서 알아보았다. 이 글에서는 간략하게 어떤식으로 표현되는지에 대해서만 적어보기로 하겠다.

```
134.75
```

이와 같은 소수가 있다. 이는 10진법으로 나타낸 소숫점으로, 2진법으로 나타내면 다음과 같다.

```
134.75(demical) = 10000110.11(binary)
```

이를 소수부와 정수부를 나누면 다음과 같다.

```
134(demical) = 10000110(binary)
0.75(demical) = 0.11(binary)
```

정수부는 오른쪽부터 2^0 인 1부터 나란히 2^¹, 2^², 2^³, 2^⁴, ... 2^ⁿ 로 구성되고(n은 자리의 끝), 소수부는 점 이하인 숫자부터 2^-1, 2^-2, ... 2^-n 으로 구성된다. 0.75 는 2^-1 * 1 + 2^-2 * 2 가 되니 위의 경우처럼 굉장히 쉽게 표현이 가능하다. 하지만 다음과 같은 숫자는 어떻게 표현할까?

```
0.9999... = 0.1111...
```

이런식으로 표기는 가능할 것이다. 하지만 컴퓨터는 유한한 데이터만을 다루기 때문에 한계가 있다.

## IEEE 754

컴퓨터에서는 숫자를 다루기 위해 여러가지 기준이 정해져 있다. 그 중에서도 소수를 나타내기 위한 기준은 IEEE 754 로 알려져 있다. 대부분의 언어에서 사용하는 _float_ 은 IEEE 754 single-precision 을 사용하여 계산된다.(_double_ 또한 마찬가지.) 데이터를 어떻게 저장하는지, 그 데이터의 표현방식은 어떻게 되는지에 대하여 간략하게 알아보자.

<br/>
![위키백과 : IEEE 754](/images/General_floating_point_ko.png){: .center-image}
<center>출처 : <a href="https://ko.wikipedia.org/wiki/IEEE_754">위키백과 : IEEE 754
</a>
</center>
<br/>

데이터의 저장 방식은 다음과 같다. 일반적으로 들어가는 부호를 위한 1bit, 그리고 우리가 아직 살펴보지 않은 지수(_exponent_), 가수(_fraction_) 부분으로 나뉘어져 있다. single-precision 을 예시로 보며 설명해보겠다.

<br/>
![Wikipedia : Single-precision floating-point format](/images/single-precision_example.png){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Single-precision_floating-point_format">Wikipedia : Single-precision floating-point format</a>
</center>
<br/>

각각의 부분이 어떠한 숫자를 저장하는지만 알면 된다. _fraction_ 은 말 그대로 소숫점 아래의 숫자만 나타내는 부분이다. 가장 왼쪽의 비트(22번쨰 비트)는 2^-1 을 저장하고 오른쪽으로 2^-2, 2^-3 이런식의 숫자에 대한 정보를 기록한다. 이렇게 실질적인 소수부와 나머지인 _exponent_ 부분이 남아 있다. _exponent_ 는 _fraction_ 숫자를 얼마나 곱하는지 나타내는 숫자다. 아래의 그림을 보자.

<br/>
![Wikipedia : Single-precision floating-point format](/images/single-precision_formatted.svg){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Single-precision_floating-point_format">Wikipedia : Single-precision floating-point format</a>
</center>
<br/>

여기서 이해가 안되는 부분이 많을 것이다. 첫번째로 맨 오른쪽의 식은 2의 지수가 음수가 되는 부분의 데이터를 나타내는 식인데, 전부다 더한 이후에 1을 더한다. 이는 숫자의 표현을 위해 넣은 부분이다. 그 다음은 중간 2의 지수가 들어가는 식에서 2^(e-127) 인데, 이는 지수를 양수, 음수로 표현하기 위한 수단이다. 양수가 된다면 가수부가 나타내는 숫자보다 큰 숫자를 나타낼 것이며, 음수가 된다면 가수부가 나타내던 숫자보다 더 작은 수를 표현할 것이다. 즉 표현하는 숫자의 범위는 굉장히 큰 것을 알 수 있다. 또한 정밀도는 보장하지 못한다는 것을 알 수 있다.

## 참조

 - [위키피디아(한글) : IEEE 754](https://ko.wikipedia.org/wiki/IEEE_754)
 - [Wikipedia : Single-precision floating-point format](https://en.wikipedia.org/wiki/Single-precision_floating-point_format)
 - [Wikipedia : Half-precision floating-point format](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)
