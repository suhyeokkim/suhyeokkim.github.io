---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
---

Windows 10 Fall Creators Update 가 나오면서 _Shader Model 6.0_ 이 추가되었다. 여태까지의 _Shader Model_ 업데이트는 대부분 DirectX 버젼이 올라가면서 같이 업데이트 된 경우가 많으나 이번의 _Shader Model 6.0_ 은 따로 업데이트 되었다. _Shader Model 6.0_ 에서의 가장 큰 기능 추가는 당연히 _Wave Intrisic_ 이라고 할 수 있겠다. _Wave Intrisic_ 을 제외하면 _Shader Model 6.0_ 은 바뀐게 없다.

여태까지의 HLSL 을 사용한 쉐이더 작성은 거의 대부분 _Single-Threading_ 으로 작동되었다. _Pixel Shader_ 에서 ddx, ddy instrisic 을 사용하여 Gradient 데이터를 가져올 수 있긴 했지만 이 것을 제외하면 거의 없었다고 보면 되겠다. 그래서 _Shader Model 6.0_ 에서는 다른 _Thread_ 와 인터렉션 할 수 있는 _Wave Intrisic_ 을 지원한다. [MSDN : HLSL Shader Model 6.0](https://msdn.microsoft.com/en-us/library/windows/desktop/mt733232.aspx) 을 살펴보면 알겠지만 단순한 API 들을 제공하는 것이다. 하지만 내부에서 동작하는 것은 조금 다르다.

[MSDN : HLSL Shader Model 6.0](https://msdn.microsoft.com/en-us/library/windows/desktop/mt733232.aspx) 에서 나온 용어에 대한 설명이 필요하다. _Lane_ 은 일반적으로 생각되는 한개의 _Thread_ 가 실행되는 것이다. _Shader Model 6.0_ 이전의 쉐이더 모델은 단순히 _Lane_ 개념 안에서 코딩을 해야 했다. _Lane_ 은 상황에 따라 실행되고 있는 상태일 수도 있고, 쉬고 있는 상태일 수도 있다. _Wave Intrisic_ 을 사용해 이를 각각의 _Lane_ 에서도 알 수 있다. _Wave_ 는 GPU 에서 실행되는 _Lane_ 의 묶음을 뜻한다. 즉 여러개의 _Lane_ 이라고 할 수 있겠다. 같은 _Wave_ 안의 _Lane_ 들은 _Barrier_ 라는게 없다. 필자가 알고 있는 _Barrier_ 는 _Memory Barrier_ 인데, 이는 _Thread_(_Lane_)끼리의 같은 메모리에 접근하는 것에 대한 동기화를 위해 있는 개념이다. 동기화를 위한 _Barrier_ 는 속도를 늦출 수 밖에 없다. 하지만 _Wave_ 로 묶여진 _Lane_ 들은 서로 _Barrier_ 가 명시적으로 존재하지 않기 때문에 _Wave_ 별로 빠른 메모리 접근이 가능하다는 것이다. _Wave_ 는 _Warp_, _WaveFront_ 라고도 불리울 수 있다고 한다.

그리고 이 API 들을 통해 약간의 드라이버 내부를 엿볼 수 있다. _Pixel Shader_ 에서 _Render Lane_ 과 _Helper Lane_ 이 구분되어져 있는데, 이는 ddx,ddy 를 통해 픽셀의 Gradient 를 계산하는 것에 대한 보다 디테일한 개념을 생각할 수 있게 해준다. GPU 드라이버 시스템에서는 픽셀을 처리하기 위해 단순히 한개의 픽셀만 처리하는게 아닌 2x2 의 픽셀을 엮어 계산한다. 이를 MSDN 문서에서는 2x2 의 픽셀 뭉치를 _Quad_ 라고 명칭한다. _Quad_ 는 두가지 종류에 스레드가 실행된다. 하나는 우리가 잘 알고 있는 _Pixel Shader_ 를 실행하는 _Render Lane_ 이다. _Render Lane_ 은 화면에 보여주는 색을 결과로 내놓게 된다. 그리고 나머지 한가지는 _Helper Lane_ 인데, 이는 Pixel 별로 Gradient 를 계산하기 위해 실행되는 _Lane_ 으로써 아무런 결과를 내놓지 않고 단순히 계산을 위한 _Lane_ 이다.

_Shader Model 6.0_ 은 DirectX12 과 Vulkan 에서 지원한다. DirectX 에서는 _Pixel Shader_ 와 _Computer Shader_ 에서 지원한다. Vulkan 에서는 모든 쉐이더 단계에서 지원한다. 그래픽 카드 벤더별로 조금씩 다른게 있으니 [GDCVault(GDC 2017) : Wave Programming D3D12 Vulkan ](http://32ipi028l5q82yhj72224m8j.wpengine.netdna-cdn.com/wp-content/uploads/2017/07/GDC2017-Wave-Programming-D3D12-Vulkan.pdf) 에서 참고 바란다.

이 API 는 여러 쓰레드들 끼리 쉽게 협력하여 보다 효율적인 쉐이더 병렬 프로그래밍을 가능하게 해줄듯하다. 다만 _Shader Model 5.0_ 에서 소개된 _ComputeShader_ 만큼의 임팩트는 없다. 패러다임의 아주 큰 변화는 없다는 뜻이다. DirectX12 가 지향하는 드라이버 시스템에서의 부담을 줄이는 것과 _Shader Model 6.0_ 은 서로 방향이 비슷하다고 생각된다.

# 참조 자료

 - [GDCVault(GDC 2017) : D3D12 & Vulkan Done Right](http://www.gdcvault.com/play/1024732/Advanced-Graphics-Tech-D3D12-and)
 - [GDCVault(GDC 2017) : Wave Programming D3D12 Vulkan ](http://32ipi028l5q82yhj72224m8j.wpengine.netdna-cdn.com/wp-content/uploads/2017/07/GDC2017-Wave-Programming-D3D12-Vulkan.pdf)
 - [MSDN : HLSL Shader Model 6.0](https://msdn.microsoft.com/en-us/library/windows/desktop/mt733232.aspx)
 - [Optocrypto : Microsoft’s first example program for shader model 6.0 was completed](http://optocrypto.com/2017/09/20/microsofts-program-shader-model-6-0-completed/)
