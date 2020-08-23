---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - microfacet
  - paper_reading
---

아무것도 모른채 _PBR_ 시스템에서의 _shading model_ 을 이해하기란 굉장히 어렵다. 거의 표준과도 같은 _cook-torrance BRDF_ 는 이름부터도 무슨소린지 쉽게 알 수 없다. 보통 가장 중요한 단어가 뒤에 붙는데, _BRDF_ 는 약어로써 더 많은 의미가 숨겨져 있다. 이를 이해하더라도 _cook-torrance BRDF_ 의 식을 본다고 방식이 쉽게 이해가 가는것도 아니다. 그래서 이에 대한 이해를 위해 이 글을 적어볼까 한다.

<!--
  시작
  physically-based? microfacet model? : microfacet BRDF is derived from microsurface model.(physically-based)
  macroscopic vs microscopic, microsurface is set of many many microfacet, all microsurface properties, functions represented by statistically

  derivation for framework.

  distribution of normal(노말 벡터의 statistically oriented), microsurface profile(microfacet 이 어떻게 구성되는지),
  masking and shadowing function(해당 micfosurface 에서 빛을 인식할 대상에게 가려지는 것, 해당 micfosurface 내에서 가려지는 것)


-->

$$ D(\omega) = \int_M \delta_\omega(\omega_m(p_m)) dp_m $$


## 참조

 - [JCGT : Understanding the masking-shadowing function in microfacet-based BRDFs](http://jcgt.org/published/0003/02/03/)
 - [Microfacet Models for Refraction through Rough Surfaces](https://www.cs.cornell.edu/~srm/publications/EGSR07-btdf.html)
- Real-Time Rendering 4th, Tomas Akenine-Möller et all, 2018
