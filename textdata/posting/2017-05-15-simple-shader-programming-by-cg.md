---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - rendering
  - cg
  - try
---

이전에 쓴 글([handling uvs and material]({{ site.baseurl }}{% post_url 2017-05-15-handling-uv-and-material-in-unity %}))에서 쉐이더에 대한 언급을 한적이 있다. 간단하게 전체적인 의미와 역할에 대해서 설명했었다. 이 글에서는 조금 더 자세하게 알아보고 CG 를 이용해서 직접 다루는 방법에 대해서 알아보겠다.

Unity 는 여러 쉐이더 언어를 지원한다. 

<!--
  쉐이더는 뭐시당가?

  shaderlab? cg? hlsl?

  CG, hlsl, glsl
  CG 를 이용해서 쉐이더 직접 만져보기
   - 표면 쉐이더 : 기본 버텍스 라이팅(diffuse vs specular)
   - 버텍스 쉐이더 & 픽셀 쉐이더 : 색, 텍스쳐, 블러

  번외 : OnRenderTexture, rendertexture
-->

## 참조

 - [Unity ref : shader references](https://docs.unity3d.com/kr/current/Manual/SL-Reference.html)
 - [Unity forum : hlsl? cg? shaderlab?](https://forum.unity3d.com/threads/hlsl-cg-shaderlab.4300/)
 - [Unity forum : CG Toolkit is legacy](https://forum.unity3d.com/threads/cg-toolkit-legacy.238181/)
 - [NVidia developer : CG Toolkit](https://developer.nvidia.com/cg-toolkit)
