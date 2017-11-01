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

_Geometry Shader_ 는 쉐이더 파이프라인에서 _Rasterizer Stage_ 넘어가기 전의 _Geometry Stage_ 의 마지막 단계로써 이전 쉐이더에서 넘긴  _Primitive_ 데이터를(point, line, triangle..) 프로그래머가 원하는 복수의 _Primitive_ 데이터로 변환할 수 있다.
