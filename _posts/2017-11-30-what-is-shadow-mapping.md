---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
---

※ 이 _Shadow Mapping_ 의 설명은 _Directional Light_ 를 기반으로 설명한다. 다른 _Light_ 들에 대해서는 언급하지 않는다.

_Shadow Mapping_ 실시간으로 그림자를 구현하기 위한 방법 중에 가장 널리 알려진 방법이다. 다른 방법들보다 구현하기 조금 쉬운편이긴 하나 이 방법은 완벽하지가 않기 때문에 방법 자체로는 완벽한 모습을 보이기 어렵고 다른 방법과 같이 사용하여 부족한 부분을 보완하여 사용해야 한다.

일반적으로 _Shadow Mapping_ 이라 말하면 아는 사람은 머릿속에 쉽게 떠오르는 방식이 있다. 빛의 반대쪽 방향에서 충분히 멀리 떨어져 한번 오브젝트를 그린다. 이때 _Pixel Shader_ 를 null 로 설정해서 _Depth Buffer_ 의 데이터만 가져온다. 또는 _Pixel Shader_ 의 출력을 _Depth_ 로 해도 된다. 그러면 보통 아래와 비슷한 2D 텍스쳐를 얻게 된다.

<br/>
![](/images/OGLTuto_DepthTexture.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

검은색에 가까워질수록(0에 가까워질수록) 해당 오브젝트의 위치가 가깝고, 흰색에 가까워질수록(1에 가까워질수록) 물체가 먼것이다. 오브젝트의 _Depth_ 를 렌더링할 때 정점에 사용되는 _MVP_ 변환 중 _View_ 변환은 임의의 위치와 빛의 방향을 계산하여 적용해준다. _Camera_ 를 기준으로 한게 아닌 _Light_ 의 방향을 기준으로 하여 관련된 것을 _Light-Space_ 라고 명명하는 경우도 더러 있다.

이제 생성된 _Shadow Map_ 을 사용하는 방법에 대해 알아보자.

<br/>
![](/images/OGLTuto_lightandshadow.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

위 그림에서 노란색으로 보이는 표면은 빛이 닿는 부분이고, 검은색으로 보이는 표면은 어떤 오브젝트에 의해 가려져 그림자가 드리운 표면이다. 해당 그림 위의 _Depth Texture_ 를 응용하여 위처럼 가려지는 표면과 안가려지는 표면을 알아낼 수 있다. 

<!--
  서론 : Light-Space Depth Map
  Generate Shadow Map
  Project Shadow Map
  PCF Filtering
-->


## 참조

 - [OpenGL Tutorial : Tutorial 16 Shadow mapping](http://www.opengl-tutorial.org/kr/intermediate-tutorials/tutorial-16-shadow-mapping/)
 - [OGLdev : Percentage Closer Filtering](http://ogldev.atspace.co.uk/www/tutorial42/tutorial42.html)
 - [GPU Gems : Chapter 11. Shadow Map Antialiasing](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch11.html)
 - [Wikipedia : SuperSampling\#poisson_disc](https://en.wikipedia.org/wiki/Supersampling#Poisson_disc)
