---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - cg
  - hlsl
  - unity
---

이번 글에서 언급할 쉐이더는 _Vertex Shader_ 다. 한글로는 _정점 쉐이더_ 라고 보통 말한다. _Vertex Shader_ 에서 할 수 있는 것은, 정점별로 들어온 정보들을 코딩을 해서 프로그래머가 원하는대로 바꾸어 다음 쉐이더에서 처리할 수 있도록 해주는 _Shader_ 다.

Unity 에서의 CG/HLSL 일반적인 _Vertex Shader_ 코드는 아래와 같다.

``` c
#pragma vertex vert
#include "UnityCG.cginc"

struct appdata_tan
{
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
}

v2f vert(appdata_tan i)
{
    v2f o;

    o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
    o.tangent = i.tangent;
    o.normal = i.normal;
    o.texcoord = i.texcoord;

    return o;
}
```

굉장히 단순한 _Vertex Shader_ 코드다. 코드가 단순한 만큼 이 _Shader_ 는 최소한의 역할만 하고 있다. _model-space_ 에 있는 정점을 _clipping-space_ 의 정점으로 변환 시켜 다음으로(fragment shader) 넘긴다. 위에서 위치 데이터를 바꿀 수 있다고 언급했는데, 이 변환은 정상적인 메커니즘을 통해 오브젝트를 출력하려면 _Rasterizer Stage_ 로 넘어가기전에 반드시 정점값에 적용시켜주어야 하는 변환이다. 해당 변환에 대해서는 [Model, View, Projection](https://docs.google.com/presentation/d/10VzsjfifKJlRTHDlBq7e8vNBTu4D5jOWUF87KYYGwlk/edit?usp=sharing)에 설명해 놓았으니 간단하게 참고하길 바란다.

위 코드에서 보여준 것들은 최소한의 것들이다. 코드를 짜는 것은 프로그래머의 역량이기 때문에 더 창의적인 것들을 할 수 있다. 쉬운 것들 중에서는 표면에서 웨이브를 주어 표면이 일렁이는 것처럼 보이게 할 수 있다. 이는 시간을 키값으로 두어 삼각함수를 이용해 할 수 있겠다.

``` C
float time;

struct appdata
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
}

v2f vert(appdata i)
{
    v2f o;

    i.vertex = i.vertex + i.normal * sin(time + i.vertex.x + i.vertex.z);
    o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);

    return o;
}
```

메쉬는 여러개의 정사각형 모양으로 잘라진 평평한 판의 형태의 메쉬를 준비하고, 간단하게 x 좌표와 z 좌표를 기준으로 오브젝트가 일렁이는 것을 만들어 보았다. 이렇게 _Vertex Shader_ 를 응용해서 정점 데이터를 프로그래머가 원하는데로 움직일 수 있다. 정점 쉐이더는 사용하기에 크게 어려운점은 없기에 _Shader_ 를 처음 다룰 때 가지고 놀만하다. 또한 _Vertex Shader_ 가 가장 응용되기 쉬운 것은 바로 _skinning_ 이다. _skinning_ 자체가 정점 데이터들을 움직이고 움직임을 기반으로 바꾸는 것이기 때문에 _Vertex Shader_ 의 형태가 _skinning_ 을 적용하기 가장 알맞다.
