---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - hlsl
---

이전 글 : "[Rasterizer]({{ site.baseurl }}{% post_url 2017-10-31-shader-pipeline-2-rasterizer %})" 에서 _Rasterizer_ 에 대해 알아보았다. 이번에는 _Fragment Shader_ 을 알아보자.

쉐이더 파이프라인에서 _Rasterizer_ 다음에 실행되는 것은 _Programmable Shader_ 중에서 _Fragment Shader_ 이다. _Fragment Shader_ 은 _Pixel Shader_ 라고도 불리는데, 이전에 _Rasterizer_ 에서 조각낸 픽셀들을 단위로 실행되기 때문에 _Pixel Shader_ 라고 불리기도 한다. 또한 각 픽셀은 조각난 단위이기 때문에 조각의 뜻을 가진 _Fragment Shader_ 라고도 불린다. 이 글에서는 _Fragment Shader_ 로 사용할 것이다.

_Fragment Shader_ 의 역할은 굉장히 단순하다. _Geometry Stage_ 에서 넘어와 _Rasterizer_ 단계에서 정리된 파라미터를 받고, 해당 픽셀의 색을 반환하면 끝난다. 역할은 단순하지만 그만큼 중요한 것이 _Fragment Shader_ 다. 마지막으로 픽셀 단위로 보여주는 색을 바꿀 수 있는 _Programmable Shader_ 로써 반복하는 비용이 꽤나 많아 일반적으로 오래 걸린다고 평가되지만 색을 바꿀 수 있어 그만큼 잘쓰면 굉장한 효과를 낼 수 있는 _Programmable Shader_ 다.

![Fragment Shader](/images/fragment_shader.jpg)

가장 단순한 형태의 Unity 에서 사용하는 CG/HLSL 쉐이더를 보자.

``` C
#pragma fragment frag

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
}

/*
  다른 코드 들..
*/

fixed4 frag(v2f i)
{
  return float4(1,1,1,1);
}
```

해당 쉐이더는 단순하게 흰색만 출력해주는 쉐이더다. 그만큼 매우 단순하고 쉽다. 하지만 많은 것들을 표현하려면 _frag_ 함수의 코드는 점점 길어질 것이다. 

또한 _Fragment Shader_ 가 실행되는 시점에서 하드웨어, 드라이버 단계에서 지원하는 기능들도 있다. 일반적인 것들에 대해서 이야기 하자면 _Depth Buffer_ 와 _Stencil Buffer_ 가 있다. 두가지의 공통점은 각 픽셀 단위별로 데이터를 저장하는 버퍼들이다. _Depth Buffer_ 는 _Clip-Space_ 로 변환된 정점 값의 Z 값을 저장하는 용도로 쓰이는 버퍼로, 요즘 개발되거나 쓰이는 기술들은 _Depth Buffer_ 를 엄청 많이 쓴다. 대표적으로 _Depth Pre-Pass_ 가 있다. _Stencil Buffer_ 는 픽셀별로 정수 데이터를 저장해서 사용하는 버퍼로써, 대부분 마스킹을 할 때 쓰인다.

# 참조 자료

 - [SlideShader : Everything about Early-Z](https://www.slideshare.net/kyruie/everything-about-earlyz)
