---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - hlsl
---

이전 포스트 "[Vertex Shader]({{ site.baseurl }}{% post_url 2017-10-30-shader-pipeline-1-vertex-shader %})" 에서 _Vertex Shader_ 에 대해 간단히 알아보았다. 이번 글에서는 _Rasterizer_ 에 대해서 간단히 써보려 한다.

_Rasterizer_ 는 쉐이더 파이프라인에 존재하는 고정 기능 단계이다. 간단하게 정의하면, _Rasterizer_ 이전 단계를 거쳐 나온 Geometry 데이터들(vertex, mesh, ...)을 정해진 해상도에 맞춰 픽셀별로 조각내어 주는 단계다. 아래 그림을 보자.

![MSDN : Traignel Rasterization Rule](https://i-msdn.sec.s-msft.com/dynimg/IC520311.png)

이는 일반적인 삼각형 폴리곤을 _Rasterizer_ 단계에서 어떻게 픽셀로 변환하는지 한눈에 알게 해놓은 사진이다. 겹치는 정도에 따라 검은색에 가깝게 해놓은 것을 볼 수있다. [MSDN : Rasterization Rules](https://msdn.microsoft.com/ko-kr/library/windows/desktop/cc627092.aspx) 에서 다른 프리미티브의 _Rasterize_ 과정도 살펴볼 수 있다.

쉐이더 파이프라인에서 _Rasterizer_ 가 가지는 의미도 조금 특별하다. 이는 3차원 메시 데이터를 2차원 이미지 데이터로 바꿔주는 과정이기 때문에 _Geometry Stage_ 에서 _Rasterizer Stage_ 로 넘어가는 관문이다.

# 참조 자료

 - [MSDN : Rasterization Rules](https://msdn.microsoft.com/ko-kr/library/windows/desktop/cc627092.aspx)
