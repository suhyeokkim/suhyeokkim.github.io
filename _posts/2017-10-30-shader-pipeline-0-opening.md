---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - hlsl
---

### 쉐이더 프로그래밍 환경

_Programmable Shader_ 들을 정리하기 위해 각 쉐이더별로 한개씩 글을 써보기로 했다. 그 전에 미리 알아야될 것들에 대해 알아보려고 한다. 각각의 _Shader_ 들은 코더의 입장에서 바라보았을 때는 단지 몇개의 파라미터를 받고 값을 반환하는 함수들이다. 하지만 일반적으로 알고있는 함수들과는 조금 다르게 실행된다. 첫번째로 일반적인 바이너리들은 CPU 에서 직렬로 실행된다. 멀티 스레드 기능을 따로 쓰지 않는한 말이다. 하지만 _Shader_ 는 기본적으로 병렬로 실행된다. 아래 그림을 보자.

![CPU core vs GPU core](/images/cpucore_vs_gpucore.jpg){: .center-image}

CPU 와 GPU 의 차이를 간단하게 보여주는 그림이다. 다만 위 그림이 전부는 아니니 간단하게 알고 넘어가도록 하자. 우리가 주목해야 할 것은 바로 _core_ 갯수의 차이다. 요즘의 CPU 는 _core_ 의 갯수가 많지 않다. 최근에 나온 [i7-8700k](https://ark.intel.com/ko/products/126684/Intel-Core-i7-8700K-Processor-12M-Cache-up-to-4_70-GHz) 를 보면 코어의 갯수가 6개 인것을 확인할 수 있다. 다만 OS 스케줄링이 있어서 실질적으로 실행되는 것은 _core_ 의 갯수에 엄격하게 제한되지는 않는다. 중요한 것은 개인용 PC 에 들어가는 CPU 는 아직은 _core_ 의 갯수가 10개를 넘어가지 않는다는 것이다. 반면에 실제 GPU 의 코어의 갯수를 꽤나 많다. 그림에서는 _hundreds of cores_, 몇백개의 _core_ 라고 하지만 요즘 개인용 PC 에 들어가는 GPU 코어는 몇천개나([gtx1080](https://www.geforce.co.uk/hardware/desktop-gpus/geforce-gtx-1080/specifications)) 된다. GPU 의 코어가 많은 이유는 간단하다. CPU 에서 돌아가는 프로그램에 비해 간단한 프로그램 바이너리(쉐이더 혹은 GPGPU 프로그램)를 동시에 실행하는게 최근의 GPU 가 쓰이는 목적이기 때문이다.

일반적으로 CPU 에서 코딩하는 프로그램과 다르게 GPU 에서 실행되는 프로그램들은 이러한 병렬적인 실행 환경 때문에 특수한 사항들과 제약사항들이 존재한다. 퍼포먼스를 염두하고 프로그램을 코딩하다 보면 처음 경험하는 프로그래머는 조금 당황스러울 수도 있다.

### 쉐이더 파이프라인

GPU 의 여태까지의 주요한 역할은 기하학적(geometry) 성격을 띄고있는 데이터들을(mesh, vertex ...) 이차원 이미지로 계산하여 보여주는 일이였다. 그렇게 3D 에셋 저작툴이나(3dsmax, maya, ...) 게임에서 GPU 를 활용해 보다 많은 것들을 표현할 수 있게 해주었다. 우리가 이번에 살펴볼 것은 _Shader Model 5.0_ 의 쉐이더가 실행되는 단계다. 이 단계는 위에서 언급한 기하학적 성격을 띄고 있는 데이터를 이차원 이미지로 계산하는 단계를 나타낸 것이다. 아래 그림을 보자.

![Shader Model 5_0 pipeline](/images/sm_5-0_pipeline.jpg){: .center-image}

이 그림에는 여러가지 항목들이 있다. _Programmable Shader_ 를 제외하면 전부 고정된 기능을 가진 단계로써 프로그래머가 완전히 제어를 할 수 없는 단계다. 우리가 살펴볼 것은 이름 끝에 _Shader_ 가 붙은 것들이다. 차례대로 _Vertex Shader_, _Hull Shader_, _Domain Shader_, _Geometry Shader_, _Pixel Shader_ 가 있다. 위의 단계들은 두가지로 분류할 수 있다. _Geometry Stage_ 와 _Rasterizer Stage_ 다. _Geometry Stage_ 는 일반적인 3D 상의 위치나 벡터를 가지고 있는 데이터를 처리하는 단계를 말한다. 위 그림에서는 _Rasterizer_ 전 까지의 단계를 뜻한다. _Rasterizer Stage_ 는 2D 이미지로 처리된 상태에서 데이터를 처리하는 단계를 말한다. _Rasterizer_ 단계 부터 오른쪽 끝까지의 단계다. 각 단계에 대한 자세한 설명은 해당 글에서 하겠다.

쉐이더 파이프라인을 알고 있어야 여러 이론들을 구현할 수 있다. 쉐이더를 다루려면 이 쉐이더 파이프라인을 아는 것은 필수라고 할 수 있겠다.
