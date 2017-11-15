---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - hlsl
  - analysis
  - hbao+
---

__HBAO+ 3.1 버젼을 기준으로 글이 작성되었습니다.__

이전 [hbao plus anatomy 2]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-anatomy-2 %}) 글에서 _Horizon based ambient occlusion_ 개념에 대해서 알아보았다. 이번 글에서는 부록의 느낌으로 _HLSL_ 코드를 읽으면서 기타 테크닉들에 대해서 써볼 것이다.

## Miscellaneous HLSL Technique

<!--
 - hlsl technique
  - not use divide
  - instruction based cacluation(especially 'dot')
  - MAD based calculation
  - hlsl cpp include
  - triangle vertex
-->

# 참조 자료

 - [NVIDIA HBAO+](http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html)
