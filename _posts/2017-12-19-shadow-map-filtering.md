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



[What is Shadow Mapping]({{ site.baseurl }}{ post_url 2017-11-30-what-is-shadow-mapping }) 에서 _Shadow Mapping_ 에 대한 간단한 번역 & 설명을 적어놓았다. 해당 글에서 _PCF_ 를 잠깐 언급했었다.

<!--
알아야 할거
  SampleCmpLevelZero, GatherRed
  PCF
  VSM
-->

<!--
 필터링과 같은 필터링 알고리즘. Shadow Map 에 두가지를 저장함. 하나는 기본 Depth 와 하나는 Depth^2 한것을 저장함. 그리고 쉐도우 맵을 Linear Sampling 하여 계산함.
-->

## 참조
 - [GPU Gems : Shadow Map Antialiasing](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch11.html)
 - [NVidia : Variance Shadow Mapping Website](http://developer.download.nvidia.com/SDK/10/direct3d/screenshots/samples/VarianceShadowMapping.html)
 - [Github : TheRealMJP - Shadows](https://github.com/TheRealMJP/Shadows)
