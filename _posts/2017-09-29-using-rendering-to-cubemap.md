---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - render
---

[using replacement shader]({{ site.baseurl }}{% post_url 2017-09-29-using-relplacement-shader %}) 에서 _Camera.RenderWithShader_ 와 같은 렌더링을 코드에서 직접해주면서 기능을 커스터마이징 할 수 있는 것을 살펴보았는데, 이 게시물에서는 비슷한 메서드인 _Camera.RenderToCubemap_ 에 대해서 알아볼 것이다.

Unity 에서는 여러 렌더링 커스터마이징 기능을 제공하는데, 이 게시물에서는 그 중 하나인 _Camera.RenderToCubemap_ 에 대해서 알아볼 것이다. 일반적으로 _Cubemap_ 은 SkyBox 나 주변의 Irradiance 를 나타낼 때 쓴다. 다만 이를 직접 구현할 때의 문제점은 각 모서리별로 _Aliasing_ 이 일어나는 경우다. 매우 매끄러운 표면의 Specular 에서 _Aliasing_ 이 나타난 Irradiance 를 표현하면 굉장히 티가 많이 나기 때문에 이는 굉장히 신경써야할 문제다.

그래서 Unity 에서는 _Cubemap_ 에 렌더링을 하는 기능인 _Camera.RenderToCubemap_ 을 지원한다. 이를 통해 할 수 있는 것은 실시간으로 _Cubemap_ 에 렌더링된 결과를 저장해 _Irradiance_ 의 소스로 쓰거나, 실시간으로 바뀌는 _Skybox_ 렌더링을 할 수도 있다. 사용 방법은 아래와 같다.

```C#
RenderTexture cubmapRT = ...;
camera.RenderToCubemap(cubemapRT, 63);
```

_Camera.RenderToCubemap_ 의 두번째로 들어가는 인자는 어떤 면을 그릴건지에 대한 비트마스크다. _Camera.RenderToCubemap_ 를 쓸때 주의할 점은 일부 하드웨어에서는 동작하지 않는 기능이라고 한다. 다만 특정한 하드웨어를 기술해 놓지않아서 추측하기는 어렵다. 단순히 추측할 수 있는 것은 MRT 를 지원하지 않거나 아니면 다른 _ComputeShader_ 같은 기능을 사용해 일부 하드웨어에서 안된다고 하는 정도 밖에 없다.

위 예제에서는 RenderTexture 를 사용하였는데, 저렇게 코드에서 처리할 수도 있지만 CustomRenderTexture 를 통해 간편하게 처리할 수도 있다. CustomRenderTexture 는 업데이트 주기를 사용자 임의대로 정할 수 있으므로 꽤나 유용하게 쓰일 수 있다.

# 참조 자료

 - [Unity Reference : Camera.RenderToCubemap](https://docs.unity3d.com/kr/current/ScriptReference/Camera.RenderToCubemap.html)
