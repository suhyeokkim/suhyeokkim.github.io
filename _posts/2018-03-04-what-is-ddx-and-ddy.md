---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - hlsl
---

_HLSL_ 에는 _ddx_ 와 _ddy_ _intrisic_ 이 _Shader Model 2.0_ 부터 존재했다. 필자는 이를 이해하기 위해 자료를 찾아보았지만 쉽게 이해되는 것들은 거의 없었다. 이해한 것을 정리하기 위해 이글을 쓴다.

예전부터 _Pixel Shader_ 를 처리할 때 픽셀 단위로 하나하나 처리하는게 아닌 적어도 2x2 개의 픽셀들을 한꺼번에 처리했다고 한다. 그래서 이러한 아키텍쳐를 이용한 키워드가 _ddx_ 와 _ddy_ 다. 기본적으로 쉐이더는 병렬로 처리되기 때문에, 4개의 _Pixel Shader_ 가 한꺼번에 실행되는 것으로 생각할 수 있다. 아래 코드를 보면서 생각해보자.

``` hlsl
    half3 dpdx = ddx(position);
    half3 dpdy = ddy(position);
```

4개의 픽셀 쉐이더가 첫번째 라인을 실행할 때 ddx 는 들어온 파라미터의 x축, 가로의 픽셀들의 파라미터의 차이를 구해 반환한다. 이는 _δ/δx_ 의 의미와 같다. 즉 x 를 기준으로 편미분을 한것이라고 한다. 마찬가지로 ddy 는 y축을 기준으로 차이를 계산해 반환하는 키워드로 생각하면 된다.

_Shader Model 5.0_ 부터는 _ddx_coarse/ddy_coarse_ 와 _ddx_fine/ddy_fine_ 으로 키워드가 나뉜다. 기존의 _ddx/ddy_ 는 _ddx_coarse/ddy_coarse_ 와 같다고 한다. _fine_ 과 _coarse_ 의 차이는 간단하다. 4개의 픽셀을 기준으로 각각의 차이를 전부 구하는게 _fine_, 한쪽의 차이만 구하는게 _coarse_ 라고 한다. 자세한 것은 아래 참조에서 보는 것을 추천한다.

## 참조
  - [MSDN HLSL Intrisic : ddx](https://msdn.microsoft.com/en-us/library/windows/desktop/bb509588.aspx)
  - [gamedev.stackexchange.net : What does ddx (hlsl) actually do?](https://gamedev.stackexchange.com/questions/62648/what-does-ddx-hlsl-actually-do)
  - [The ryg blog : A trip through the Graphics Pipeline 2011, part 8](https://fgiesen.wordpress.com/2011/07/10/a-trip-through-the-graphics-pipeline-2011-part-8/#comment-1990)
  - [MSDN Shader Model Assembly 5.0 : deriv_rtx_fine](https://msdn.microsoft.com/en-us/library/windows/desktop/hh446950.aspx)
  - [MSDN Shader Model Assembly 5.0 : deriv_rtx_coarse ](https://msdn.microsoft.com/en-us/library/windows/desktop/hh446948.aspx)
