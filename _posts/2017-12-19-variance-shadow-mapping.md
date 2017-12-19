---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - vsm
---

<!--
    PCF 필터링과 같은 필터링 알고리즘. Shadow Map 에 두가지를 저장함. 하나는 기본 Depth 와 하나는 Depth^2 한것을 저장함. 그리고 쉐도우 맵을 Linear Sampling 하여 계산함.
-->

## 참조

 - [NVidia : Variance Shadow Mapping Manual ](http://developer.download.nvidia.com/SDK/10.5/direct3d/Source/VarianceShadowMapping/Doc/VarianceShadowMapping.pdf)
 - [NVidia : Variance Shadow Mapping Website](http://developer.download.nvidia.com/SDK/10/direct3d/screenshots/samples/VarianceShadowMapping.html)
 - [Github : TheRealMJP - Shadows](https://github.com/TheRealMJP/Shadows)
