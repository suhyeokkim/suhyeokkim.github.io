---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  
---


일반적인 응용 프로그램들은 중간중간에 잠시 멈춰도 원하는 결과를 유저에게 보여주면 상관이 없다. 하지만 게임은 '게임중' 에는 어떤 경우에도 렉을 허용하지 않는다. 그만큼 '게임중' 상태에서 렉을 아예 발생시키지 않는 것이 게임 프로그래머의 중요한 능력중 하나다.

게임은 일반적으로 1초에 60번 이상 업데이트하는 루틴을 유지해야 유저에게 원활한 환경을 제공한다. 여기서 급작스럽게 프레임수가 하락하면 그때 유저들은 순간적으로 끊기거나 부드럽지 않은 경험을 하게된다. 유저들은 그런 것들을 랙으로 통칭한다. 랙이 반복되면 유저들은 게이밍 환경에 불만을 느끼게 된다.

일반적인 랙은 프로그래머의 실수인 경우가 많다. 런타임에서 많은 것을 한꺼번에 처리하는 경우가 대표적이다. 하지만 이는 여러 리팩토링을 거치면 충분히 해결할 수 있다. 경험이 적은 사람들에게 가장 문제가 되는 것은 엔진을 사용하는 방법이 문제가 되는 경우가 많다. 엔진의 자세한 구현 사항을 파악하지 못했기 때문에 한계를 생각하지 않고 코딩하는 경우 말이다. 몇가지 사항들만 주의하며 코딩한다면 꽤 많은 병목들을 피해갈 수 있다.

이제 Unity 엔진을 사용할 때 퍼포먼스에 영향을 끼치는 것들과 해결 방안에 대해서 알아보자.

<!-- more -->

만들어진 소프트웨어를 최대한 플랫폼의 자원을 덜 소모하고 빠르게 작업을 수행하게하는 것을 "최적화를 한다" 라고 한다. 게임이라는 소프트웨어의 최적화는 보통 게임 플레이 시간에 매 프레임 별로 최대한 시간을 덜 소모하게 하는 것을 일반적으로 여겨진다.

그래서 Unity 는 게임 플레이 시간동안 걸리는 작업들의 시간을 측정하는 툴을 지원한다. 이름은 _Profiler_ 라고 한다. _Profiler_ 를 통해 시간이 많이 걸리는 부분을 찾을 수 있다. [Unity 메뉴얼](https://docs.unity3d.com/kr/current/Manual/ProfilerWindow.html)에서 자세한 사용법을 확인하면 된다.

![Unity Profiler](https://docs.unity3d.com/kr/current/uploads/Main/ProfilerTimeline.png){: .center-image}

위 그림은 일반적인 CPU 시간을 잴 때 사용하는 모드로써 위에서 언급한 스크립트의 실행시간을 체크할 때 쓸 수 있는 모드 중 하나다. 직접 켜보면(Window -> Profiler) 알 수 있듯이 CPU 시간 말고도 다른 특수한 작업들의 디테일한 사항을 볼 수 있다. 실시간으로 렌더링 되는 것들을 체크할 수 있는 __Rendering__ 모드, 메모리를 얼마나 쓰는지 확인할 수 있는 __Memory__ 모드, Unity 에서 가져다 쓰는 물리엔진 _PhysX_ 에서 주로퍼포먼스에 영향을 끼치는 것들에 대하여 정보를 나타내주는 __Physics__ 모드 등 꽤 많은 것들이 있다. 실시간으로 대부분의 문제를 찾을 수 있기 때문에 꽤 많은 시간들을 줄여준다.

게다가 더욱더 강력하다고 생각되는 사실은 __Android__ 플랫폼에서 이 _Profiler_ 를 사용가능 하다는 것이다. _ADB_ 라는 디버깅 유닛이 있는데, Unity 에서는 이 유닛을 직접 사용하여 연결만 잘 되어있다면 프로파일러를 돌려볼 수 있다.

Unity 에서는 꽤나 좋은 _Profiler_ 를 지원한다. 시간이 난다면 게임을 처음부터 끝까지 몇번 돌려보길 바란다. 문제가 생겼을 때 돌려보는 것 보단 되도록 자주 체크하여 항상 문제가 있는지 없는지 체크해보는 것이 좋다. 시간이 없을 떄 처리하려면 골치아픈 문제가 되겠지만 시간이 여유로울 떄 발견하면 아주 큰 문제가 아닌 이상 처리하기는 편할 것이다. 또한 _Profiler_ 는 자신의 컴퓨터의 처리 속도를 체크하는 것이다. 그러므로 자신의 컴퓨터가 아주 좋은 플랫폼이라면 안좋은 플랫폼에서도 디버깅을 해보는 것도 좋을 것이다.

## Hierachy and component based development

Unity 는 _Scene_ 이라 불리는 데이터 안에 여러 _GameObject_ 의 세팅을 넣어놓고 저장된 _GameObject_ 에 붙어있는 _Component_ 의 동작에 의해 게임이 돌아간다. 실제로 Unity 에서 동작하는 것들은 _Component_ 들인데 이렇게 여러 오브젝트들에 각자 _Component_ 를 붙여 동작하는 개발 방식을 CBD(Comnent based development) 라고 한다. Unity 는 CBD 를 근본적인 개념으로 차용해 정해져 있는 형식 없이 개발하도록 지원한다.

Unity 는 CBD 를 밑바닥부터 구현하도록 지원하지만 이게 꼭 좋은 것은 아니다. 특히 성능상으로 따졌을 떄 컴포넌트가 많이 존재하면 존재할수록 컴포넌트들 안에 Unity 시스템에서 받는 메세지 메소드들이 많이 구현되어 있을수록 약간의 부하가 발생한다. (물론 절대적인 몇천개, 몇백개의 갯수를 뜻한다. CPU 의 성능에 따라 모바일에서는 간단한 수학 연산을 하는 몇십개의 메소드도 부담스러울수도 있다.) 제일 문제가 되는 부분은 _MonoBehaviour.Update_ 류의 메소드들이다.(_MonoBehaviour.LateUpdate_, _MonoBehaviour.FixedUpdate_) 이 메소드들은 매 프레임마다 호출되어야 하는 메소드들인데 이 메소드를 받는 컴포넌트들이 많으면 많을수록 부담되는 것은 사실이다.

일반적인 상황에서는 한 메소드가 같은 프레임에 몇백번 이상 호출될 일은 없겠지만 그럴 일이 있다면 미리 합쳐주는 것을 추천한다.

## PhysX

Unity 의 물리 기능은 서드파티 라이브러리인 _PhysX_ 를 탑재하여 기본으로 물리 기능을 지원한다. _PhysX_ 는 GameWorks 라는 게임 개발을 위한 미들웨어 제품 그룹에 있던 라이브러리 중 하나다. 그래서 우리는 About Unity 창을 열면 꽤 큼지막하게 자리를 차지하는 _PhysX_ 의 로고를 볼 수 있다.

![About Unity](/images/about_unity.png){: .center-image}

Unity 에서 PhsyX 는 물리 엔진으로서 자리 잡고 있는 것을 볼 수 있다. 하지만 PhsyX 는 자원이 한정되어 있는 플랫폼에서는 잘 사용해주어야 한다. 몇가지를 세팅해주어 한정적으로 돌아가게 해야되는데 해주어야 세팅들을 살펴보자.

#### Physics Setting : layer collision matrix

Unity 에서는 __GameObject__ 별로 _layer_ 를 설정해주어 여러가지 설정을 한다. 대표적인 예는 카메라에서 어떤 오브젝트를 그릴지 _layer_ 마스크를 통하는 것이다. 그리고 PhsyX 에서 돌아가는 물리 세팅도 _layer_ 기반으로 검사를 한다. 충돌 검사를 하는 연산이 많으면 많을수록 성능에 그다지 안좋은 영향을 끼치기에 _layer_ 별로 검사할 것들을 설정해 줄 수 있다. 아래 그림을 보자.

![Physics setting](/images/physics_settings.png){: .center-image}

여기는 Edit -> Project Settings -> Physics 으로 들어올 수 있는 프로젝트 별로 물리 관련된 옵션을 세팅해주는 곳이다. 여기서 Layer Collision Matrix 를 보면 된다. 이 이상하게 생긴 체크박스들은 해당 레이어와 충돌 체크를 하여 물리 연산을 하는지 안하는지에 대한 세팅 값이다. 이 부분만 체크해주어도 쓸데없는 연산을 없엘 수 있으니 신경써서 잘 체크해주길 바란다.

#### Time Setting : Fixed Timestamp

이제 언급하려는 부분은 상당히 게임에서 민감한 부분이다. 물리 기능을 하는 루프는 정확한 계산을 위해 일정 시간마다 체크를 하는데 이 체크를 하는 시간 주기를 Edit -> Project Settings -> Time 에서 변경할 수 있다.

![Timer Setting](/images/setting_timer.png)

맨 처음에 보이는 Fixed Timestep 을 직접 바꾸어줄 수 있다. 이 숫자를 늘리면 매 프레임별 부하는 줄어들지만 정확성이 줄어든다. 이 숫자를 줄이면 매 프레임별 부하는 커지지만 물리 계산 결과는 정확해진다. 하지만 한가지 명심할 것이 있다. 이 부분은 실제 체크하는 부분을 담당하기 때문에 이미 만들어진 게임에서 이 숫자를 바꾸면 무슨일이 일어날지 모른다. 반드시 만들어진 게임에서, 특히 Collider 를 많이 쓰는 게임에서는 이 숫자를 철저한 검사후에 바꿔주어야 한다. 물론 Unity 의 물리 계산을 아예 안쓸거라면 엄청 크게 해주면 된다.

#### 절대적인 Collider 의 갯수

위에서 GameObject 의 갯수에 대해서 말했었다. 이와 같이 Collider 의 갯수는 많으면 많을 수록 다른 레이어의 오브젝트들과 비교하는 대상이 많아지므로 더욱더 부하가 커진다. 즉 적절한 Collider 의 갯수도 중요하다.

## Garbage Collection

Unity 는 개발 언어와 여러 환경을 위해 __Mono__ 프레임워크를 사용한다. 그리고 __Mono__ 프레임워크에서는 메모리 관리를 위해 __Garbage Collector__ 를 사용한다. GC 를 사용하게 되면 가끔씩 __Garbage Collection__ 이 발생하는데 이 __Garbage Collection__ 은 게이밍 환경에서는 정말 최악의 행동이다. 대부분 __Garbage Collection__ 은 꽤나 시간이 걸리기 때문에 잠깐 끊기는 현상이 발생할 수 밖에 없다. 결국 게임 중에는 절~~대로 쓰레기(Garbage) 메모리를 만들면 안된다. 게임 시간이 얼마나 길어질지 모르고 플랫폼의 특성도 모르기 때문에 게임 중에는 쓰레기 메모리를 절대 안 만드는게 가장 안전하다. 위에서 언급한 _Profiler_ 를 통해 쓰레기 메모리들이 얼마나 발생하는지 GC Alloc 탭에서 체크할 수 있다.  __Deep Profile__ 기능까지 사용하면 메소드 단위로 알 수 있기 때문에 쓰레기 메모리를 만드는 부분을 하나하나 체크하여 없에는 것이 중요하다. 쓰레기를 발생시키는 코드의 유형은 꽤나 많기 때문에 여기서는 언급하지 않겠다.

## Drawcall and Batching

Graphics API 에서는 물체를 그릴려면 여러 준비를 해야한다. 이 준비는 어느 정도의 시간이 걸리기 때문에 많으면 많을수록 상당히 부담스럽다. 준비를 마치면 GPU 에 그려달라는 명령을 한다. 이 명령을 _Draw Call_ 이라고 한다. _Draw Call_ 의 숫자는 모바일 게임의 경우 아무리 많아도 몇십개로 유지해야하며 고사양 PC 게임은 몇백단위로 유지해야 한다고 한다. 왜냐하면 _Draw Call_ 의 횟수가 많으면 많을수록 CPU 에서 부담하는 것들이 많아지기 때문에 결국 FPS 하락으로 이어질 수밖에 없다. 그런데 Unity 에서는 _Draw Call_ 이라는 단어는 엔진을 사용할 때 볼일이 하나도 없다. 이렇게 중요한데 왜 없냐하면 Unity 는 이 _Draw Call_ 을 줄이기 위해 엔진 내부에서 처리를 하는데 이를 _Batching_ 이라고 한다. 결국 _Draw Call_ 과 같은 단어지만 일정한 조건만 지키면 알아서 _Batching_ 카운트를 줄여준다. Unity 에서 최대한 _Batching_ 카운트를 줄이는 방법에 대하여 알아보자. 우선은 엔진에서 지원하는 것들에 대하여 알아보자.

Unity 에서는 _Draw Call_ 을 줄이기 위해 _Static Batching_ 과 _Dynamic Batching_ 이 두가지 기능을 지원한다.  _Static Batching_ 은 움직이지 않는 오브젝트들을 세팅할 때 한꺼번에 그리는 기능이다. 만약 움직이는 오브젝트라면 항상 위치를 갱신해주어야 하기 때문에 준비를 다시해야 하지만 움직이지 않는 오브젝트라면 미리 움직이지 않는다고 체크를 하고 그대로 위치를 가지고 GPU 에서 그려주면 되기 때문이다.

또한 전제조건으로 메터리얼을 공유해야 한다는 조건이 있다. 메터리얼에는 여러 인자와 쉐이더가 세팅되어 있는데 이 메터리얼을 공유해야 한다는 조건은 같은 쉐이더를 사용해야 _Batching_ 카운트를 합칠 수 있다는 이야기다.

아래는 _Static Batching_ 을 에디터에서 세팅해주는 사진이다.

![Static Tag Inspector](https://docs.unity3d.com/kr/current/uploads/Main/StaticTagInspector.png)

_Dynamic Batching_ 움직이는 오브젝트들이 같은 메터리얼을 공유하면 한꺼번에 그려주는 기능이다. 하지만 _Dynamic Batching_ 은 약간의 기능상의 한계가 있다. 아래 레퍼런스 링크로 들어가서 확인해보면 알 수 있다.

[DrawCallBatching](https://docs.unity3d.com/kr/current/Manual/DrawCallBatching.html) 에서 자세한 내용을 확인할 수 있다.

## 참조

 - [Google IO 2014 : Optimizing unity games](https://www.slideshare.net/AlexanderDolbilov/google-i-o-2014)
 - [Optimize shader](http://shimans.tistory.com/41)
 - [Wikipedia : PhysX](https://en.wikipedia.org/wiki/PhysX)
