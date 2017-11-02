---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - hlsl
---

"[Fragemnt Shader]({{ site.baseurl }}{% post_url 2017-10-31-shader-pipeline-3-fragment-shader0 %})" 에서 _Fragment Shader_ 에 대해 알아보았다. 다음은 _Geometry Shader_ 에 대해서 써보려 한다.

_Geometry Shader_ 는 쉐이더 파이프라인에서 _Rasterizer Stage_ 넘어가기 전의 _Geometry Stage_ 의 마지막 단계로써 이전 쉐이더에서 넘긴  _Primitive_ 데이터(point, line, triangle..)를 프로그래머가 원하는 복수의 _Primitive_ 데이터로 변환할 수 있다. 삼각형을 삼각형의 중심을 나타내는 점으로 변환하는 쉐이더를 보자.

``` C

[maxvertexcount(1)]
void geom(v2g input[3], inout PointStream<g2f> pointStream)
{
    g2f o;

    o.vertex = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

    pointStream.Append(o);
}

```

# 참조 자료

 - [MSDN : Geometry-Shader Object](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509609.aspx)
 - [MSDN : How To: Index Multiple Output Streams](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471424.aspx)
 - [MSDN : How To: Instance a Geometry Shader](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471425.aspx)
