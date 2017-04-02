---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: false
categories:
  - unity
  - c#
  - csharp
  - analysis
---

Unity 에서 객체간의 이벤트를 처리하는 방법들을 써본다. c# 에서 지원하는 delegate, event 와 UnityEvent 를 알아볼 것이다.

## C# Delegate, Event

#### 행동을 대신하다. Delegate

대리자(Delgate) 의 개념이 고안된지는 꽤 많은 시간이 흘렀다. 시작으로 거슬러 올라가면, 가장 사람들이 많이 접한 형태는 Windows API 의 메세지 처리 콜백 함수가 있겠다. 긴말 필요없이 간단한 예제를 살펴보자.

{% highlight c# lineos %}
//
// delegate 를 이용한 간단한 Unity 예제다.  
//

public delegate void CheckForAwake();
public CheckForAwake onAwake;

void Awake()
{
  // 단순히 함수를 대입한다.
  onAwake = LogAwake;
  if(onAwake != null) onAwake.Invoke();

  // 람다식을 += 를 사용해 onAwake 델리게이트에 추가한다.
  CheckForAwake otherAwake = () => Debug.Log("Awake!! Twice!!");
  onAwake += otherAwake;
  if(onAwake != null) onAwake.Invoke();

  // 람다식을 -= 를 사용해 onAwake 델리게이트에서 지운다.
  onAwake -= otherAwake;
  if(onAwake != null) onAwake.Invoke();

  // null 을 넣어 빈 델리게이트를 표현한다.
  onAwake = null;
}

void Start()
{
  if(onAwake != null) onAwake.Invoke();
}

void LogAwake()
{
  Debug.Log("Awake!!");
}
{% endhighlight %}

위의 예제는 대리자(Delgate)의 사용방법을 보여준다. 대리자(Delgate)는 단순히 대입을 통해 한개의 함수만 넣을 수도 있고, '+', '-' 연산자들을 통해 여러개의 함수를 가질수도 있다. 다만 같은 인자, 같은 반환형을 가져야 위와 같이 사용할 수 있다.

위 예제를 살펴보았을 때 대리자(Delgate)는 함수들을 여러개 가질 수도 있고, null 값을 가질수 있는 자료형이라고 칭할 수 있겠다.

그리고 일일히 타입을 지정하지 않고도 미리 지정된 대리자들을 사용가능하다. (참고 : [Action](https://msdn.microsoft.com/ko-kr/library/018hxwa8.aspx), [Func](https://msdn.microsoft.com/ko-kr/library/bb549151.aspx) 등 많은 타입이 있다.)

#### 특정 정보를 전달해준다. Event

C# 에서 event 키워드는 대리자(Delgate) 선언에 같이 쓸 수 있는 키워드로, 선언된 대리자(Delgate)의 접근을 제한하는 역할을 한다. 근데 "접근을 제한할려면 접근 키워드를 쓰지 왜 event 라는 다른 키워드를 쓰는 것인가?" 라는 생각이 들 수도 있다. 역시 아래 예제를 보면서 설명하겠다.

{% highlight c# lineos %}
//
// 씬 로드 event 를 이용한 예제다.
//

// 대리자 이벤트 변수
public event Action<UnityEngine.SceneManagement.Scene, UnityEngine.SceneManagement.LoadSceneMode> onLoad;

void Awake()
{
  // 자기 자신의 대리자 이벤트 변수는 어떤 접근도 가능함.
  onLoad = OnSceneLoaded;
  onLoad = null;
  onLoad += OnSceneLoaded;

  // 컴파일 에러! 외부의 event 변수는 assign 이 안됨.
  // SceneManager.sceneLoaded = onLoad;

  // += 접근은 가능함.
  SceneManager.sceneLoaded += onLoad;
}

void OnDestroy()
{
  // 컴파일 에러! 외부의 event 변수는 assign 이 안됨.
  // SceneManager.sceneLoaded = null;

  // -= 접근은 가능함.
  SceneManager.sceneLoaded -= onLoad;
}

void OnSceneLoaded(UnityEngine.SceneManagement.Scene scene, UnityEngine.SceneManagement.LoadSceneMode mode)
{
  Debug.Log(string.Format("{0}, {1}", scene.name, mode.ToString());
}
{% endhighlight %}

위의 코드는 event 의 접근 제한이 어디에 걸려있는지 알 수 있다. 자기 자신의 이벤트 대리자는 얼마든지 접근이 가능하지만, 외부에서 이벤트 대리자를 접근할 때는 대입 연산자는 불가능하고, 등록(+=) 하거나 취소(-=) 하는 연산자만 쓸 수 있다.

즉 이벤트 키워드는 대리자 자체를 이벤트를 알려주는 옵저버 패턴의 형태로 만들어 주는 역할을 한다.

## Serializable 한 이벤트 : UnityEvent

Unity 에서는 이벤트 대리자를 Serializable 한 class 로 만들어 저장이 가능한 UnityEvent 를 제공한다. UnityEvent 는 두가지의 방법으로 사용할 수 있다. 하나는 에디터에서 객체와 대리자 정보를 저장해 데이터로 저장되는 지속성 이벤트와, 런타임에서 c# 이벤트 대리자 처럼 사용하는 방법이 있다. 두가지 방법 모두다 이벤트 대리자를 쓰는 방식과 동일하다. 단지 메소드를 저장하는 방식의 차이일 뿐이다.

지속성 이벤트에 등록하려면 두가지 요구조건이 있다. static 함수가 아니여야 하며, 접근 제한자는 public 으로 설정되어 있어야 Unity 에디터에서 등록이 가능하다.

UnityEvent 는 원하는 파라미터를 커스터마이징해서 사용 가능하다. [UnityEvent 제너릭 클래스 상속](https://docs.unity3d.com/ScriptReference/Events.UnityEvent_1.html)을 통해 지원하며 최대 4개까지 지원한다. 또한 클래스를 선언할 때 System.Serializable 어트리뷰트를 붙여주어야 Serialize 가 되어 인스펙터에서 볼 수 있다.

UnityEvent 에 등록하면 인자를 전달하는 두가지 방식을 선택할 수 있다. 하나는 정해진 인자를 전달하는 static parameter 방식, 나머지 하나는 해당 UnityEvent 의 정해진 인자와 등록하려는 메소드의 인자가 동일하면 인자들을 그대로 등록한 메소드에 넘기는 dynamic parameter 방식이 있다.

예제 : [DelegateEventExample]({{ site.url }}/assets/examples/DelegateEventExample.zip)

# 제대로 된 예제를 넣어놓아야 함. 시발 모르겟다 좆됫음.

## 실제 사용 사례 및 장단점

실제로는 한 씬에서 UI 로직을 구성할 때 가장 많이 쓰인다. UGUI 의 많은 위젯들도 UnityEvent 로 여러 입력들을 알려준다. UI 전용 이벤트를 처리해주는 EventTrigger 라는 컴포넌트도 있을 정도로 UnityEvent 를 많이 활용한다. 실제 작업할 때는 UI Widget 하나에 여러 Event 를 붙여 다른 Widget 에 연결시켜 사용하는게 가장 편하다.

게임 로직도 UnityEvent 로 구성하면 만들때는 쉽지만 UnityEvent 는 가독성이 상당히 안좋기 때문에 게임 로직을 구성하면 나중에는 손댈수 없는 스파게티 덩어리가 만들어질 것이다. MVVM 구조에서는 유용하게 쓰일 수도 있다. 또한 빠른 작업속도로 프로토타입에는 적합하다.

## 참조

[MSDN 방법: 대리자 선언, 인스턴스화 및 사용](https://msdn.microsoft.com/ko-kr/library/ms173176.aspx)
[MSDN C# Delegate](https://msdn.microsoft.com/ko-kr/library/ms173172.aspx)
[MSDN C# Event](https://msdn.microsoft.com/ko-kr/library/awbftdfh.aspx)
[Event Performance](http://jacksondunstan.com/articles/3335)
[UnityEvent Manual](https://docs.unity3d.com/kr/current/Manual/UnityEvents.html)
