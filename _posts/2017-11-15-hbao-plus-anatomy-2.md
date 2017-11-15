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

이전 [hbao plus anatomy 1]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-anatomy-1 %}) 글에서 _HBAO+_ 에 들어간 여러 테크닉들과 구조에 대해서 써보았다. 이번 글에서는 가장 중요한 _Horizon based ambiend occlusion_ 에 대해서 써볼 것이다.

## Horizon Based Ambient Occlusion

<!--
- hbao
 - horizon based calculation
  - every direction
 - bias
 - falloff
 - bileteral blur
-->

# 참조 자료

- [Image-Space Horizon Based Ambient Occlusion](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509609.aspx)
