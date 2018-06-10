---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - math
  - floating_point
---

코딩을 하던 도중, 비트로 나타내어진 2 byte floating number(half-precision) 데이터를 일반적인 4byte floating number(single-precision) 으로 나타내야 할 일이 있었다. 그래서 귀찮아서 알아보지 않았던 컴퓨터의 소수를 표현하는 방법에 대해서 알아보았다. 이 글에서는 간략하게 어떤식으로 표현되는지에 대해서만 적어보기로 하겠다.

<!-- more -->

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

여기서 이해가 안되는 부분이 많을 것이다. 첫번째로 맨 오른쪽의 식은 2의 지수가 음수가 되는 부분의 데이터를 나타내는 식인데, 전부다 더한 이후에 1을 더한다. 소수점을 표현하는 _fraction_ 이 0일 경우에 예외처리를 위해 1을 더한다. _fraction_ 이 단순히 소수를 표현한다면 왼쪽의 _exponent_ 부분은 _fraciton_ 에 값에 2진수의 자릿수 올림을 해주는 값이다. _exponent_ 는 가변적으로 2진수의 자릿수를 크게하거나 0에 가깝게 작게하여 가변적으로 숫자를 표현할 수 있게 해주는 매우 중요한 부분이다. 하지만 이 방식은 10^1023 + 10^-2353 * 1 같은 큰 숫자와 매우 작은 숫자의 표현은 불가능하다. 일반적으로는 작은 부분에 신경을 쓰지 않기 때문에 큰 부분을 정확하게 맞추고 작은 부분은 오차를 나게 한다. 그래서 가끔 2.999999 이런 숫자가 나오는 것이다.

## 참조

 - [위키피디아(한글) : IEEE 754](https://ko.wikipedia.org/wiki/IEEE_754)
 - [Wikipedia : Single-precision floating-point format](https://en.wikipedia.org/wiki/Single-precision_floating-point_format)
 - [Wikipedia : Half-precision floating-point format](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)
