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


<!--
[Handling rigging and skinning]({{ site.baseurl }}{% post_url 2017-05-19-handling-rig-and-skinning %}) 글 에서 케릭터의 뼈를 심고 그 뼈를 따라 정점을 움직이게 하는 방법에 대해서 알아보았다. 이번 글에서는 Unity 에서 간단하게 _Shader_ 를 다뤄볼 예정이다.

우선 _Shader_ 에 대해 말하기 전에, 알아야 할것들이 있다. 바로 일반적으로 알려진 _Rendering Pipeline_ 이다. _Rendering Pipeline_ 이란 한 프레임별로 실제 렌더링이 이루어지는 과정 자체를 말하며, 각 과정별로 소프트웨어와 하드웨어의 동작이 섞여있어 정확하게 알려면 꽤 많은 시간을 투자해야한다. 우선은 우리가 건드려야할 부분의 간단한 설명만 해보겠다.

![pipeline](/images/Graphics3D_Pipe.png)
-->


<!--
  forward rendering
  deferred rendering

  phong reflecton = Ambient Light, Diffuse Light, Specular Reflection
  physics based rendering = reflection + albedo + refraction
    sRGB
    gamma correction
    bdrf vs bsrf vs btdf

  screen space ambient occlusion
  per-vertex ambient occlution
-->

## 참조

 - [GameDev : forward rendering vs deferred rendering](https://gamedevelopment.tutsplus.com/articles/forward-rendering-vs-deferred-rendering--gamedev-12342)
 - [Wikipedia : Deferred shading](https://en.wikipedia.org/wiki/Deferred_shading)
 - [LearnOGL : Deferred shading](https://learnopengl.com/#!Advanced-Lighting/Deferred-Shading)
 - [Ambient Light, Diffuse Light, Specular Reflectio](http://celdee.tistory.com/525)
 - [PBR For Artist](http://m.blog.naver.com/blue9954/220404249147)
