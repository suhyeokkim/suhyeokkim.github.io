---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - translate
  
---

[GameDev : structured buffer vs constant buffer](https://www.gamedev.net/forums/topic/624529-structured-buffers-vs-constant-buffers/)의 답변 해석 글이다.

<!-- more -->

### 유저 tsus 의 답변.

첫번째로 메모리 액세스가 다르게 작동한다.

_cbuffer_ 는 모든 스레드(역자 : GPU 안의 각각의 코어에서 도는 스레드) 에서 동일한 값을 Warp하게(정확히 뜻을 모르겠다) 접근하면 엄청나게 빠르다. 하지만 스레드 각각 다른 지점(역자 : 장소? 배열의 인덱싱을 말하는 듯 하다)를 접근하면 데이터를 읽는 방식이 직렬화된다. 이 현상은 _Constant Waterfalling_ 이라고 불리며 읽는 속도를 굉장히 느리게한다. 이는 뼈 애니메이션(역자 : 스키닝)을 하려는 사람들에게 두통을 유발한다. 설명한 세가지 시나리오 중 마지막 시나리오를 빼고 전부 _cbuffer_ 를 사용한다.

_StructuredBuffer_ 는 _cbuffer_ 와 다르게 _통합 캐시 구조_ 를 사용하여 최적화했다. _통합 캐시 구조_ 는 첫번째 읽는 속도는 느리지만 뒤에 같은 데이터를 다시 읽는 것은 빠르다는 것이다.(물론 캐싱된 경우를 뜻한다.)

두번째로 사용이 제한되어 있다.

_cbuffer_ 는 특수 레지스터에 존재하기 때문에 굉장히 빠르다. 하지만 레지스터의 크기는 64kb 로 굉장히 작다. _StructuredBuffer_ 는 레지스터에 저장되지 않으므로 더 많은 공간을 사용할 수 있다. 즉 저장된 데이터가 많아지면 _StructedBuffer_ 를 사용해야 한다.

_StructuredBuffer_ 는 렌더링 파이프 라인 어느 지점에서도 바인딩 할 수 없다.(역자 : 바인딩의 뜻을 모름니다;) 이는 정점 버퍼처럼 취급되지 않는다는 것을 뜻한다. DirectX10 의 하드웨어는 임의의 접근을 통한 쓰기를 타입을 가진 리소스(텍스쳐, 정점 버퍼)에 지원하지 않기 때문에 DirectCompute 를 DirectX10 에서 지원했다. 그래서 모든 쉐이더 단계에서 _StructuredBuffer_ 를 읽을 수 있게 되었다.

_StructuredBuffer_ 는 숨겨진 꿀(?) 기능이 있다.(역자 : 그다지 꿀인지는 모르겠는데..) 접근한 스레드의 갯수를 세서 다른 여러 스레드에서 접근하게 해주는 _"hidden counter"_ 라는 기능이다. 게다가 이 카운터는 _ByteAddressBuffer_ 에 _interlockedAdd_ 를 사용하는 것 보다 조금 빠르다. _ByteAddressBuffer_ 는 _StructuredBuffer_ 와는 다르게 형식이 정해져 있지 않아 어디에든지 바인딩이 될 수 있는 버퍼다.

### 운영자 MJP 의 답변

"Constant" 라는 단어는 쉐이더 프로그램이 실행될 동안 값이 일정하다는 것을 나타내며 CPU 값을 변경할 수 없다는것은 아니다. 이 단어는 DX10 이전에 나온 단어로써 쉐이더에 정의된 소수의 상수를 _Shader Constants_ 라고 했을 때 나온 단어다.

_Constant Buffer_ 는 작은 양의 원하는(역자 : heterogeneous 라고 표기하는데 이해가 안됨.) 값들을 쉐이더에서 이름을 가지게 하여 직접 접근하게 하려는 목적을 가지고 있다. 그래서 첫번째 예의 _View Matrix_ 와 _Projection Natrix_ 를 가지는 예제는 _Constant Buffer_ 에 완벽하게 어울린다.

_StructuredBuffer_ 는 구조체 배열과 같이 원하는 구조체의 배열을 뜻한다. 그래서 인덱스로 여러개를 접근할만한 데이터가 있다면 _StructuredBuffer_ 를 사용하는 걸 원할 것이다. 3번째로 예를든 조명 리스트는 _StructuredBuffer_ 를 사용하기 좋다.

DOF 쉐이더는 둘다 사용가능하다. _StructuredBuffer_ 를 쓰고 데이터를 반복해서 읽으면 조금 부담스럽지만 가능은 하다. _StructuredBuffer_ 는 읽기 동작을 계속 반복하지만, 정적 _cbuffer_ 읽기 동작은 더 최적화 되어있다. 정적 _cbuffer_ 읽기는 반복문이(Loop) 없어야 한다. Loop 가 존재하면 다른 쉐이더의 순열(역자 : permutations 라고 적혀있음, 의역 불능)이 필요할 수도 있다.

어쨋든 현대 GPU 하드웨어는 일반적으로 동작하며, API 에서 제공하는 추상화간에 큰 차이는 거의 없다. 하드웨어가 덜 유연한 DX9 포함 이전 버젼의 GPU 들과는 많이 다르다. 다만 적절한 성능을 찾고싶다면 프로파일링을 해야한다.

보통 프로그래머의 관점에서는 _cbuffer_ 와 _StructuredBuffer_ 는 비슷하게 보인다. 하지만 두 버퍼는 꽤 중요한 차이점이 있다.
