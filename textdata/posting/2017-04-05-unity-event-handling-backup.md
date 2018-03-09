---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - c#
  - analysis
---

Unity 에서 객체간의 이벤트를 처리하는 방법들을 써본다. c# 에서 지원하는 delegate, event 와 UnityEvent 를 알아볼 것이다.
<!-- more -->
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
using UnityEngine.Events;
using UnityEngine.SceneManagement;

//
// 씬 로드 event 를 이용한 예제다.
//

// 대리자 이벤트 변수
public event UnityAction<Scene, LoadSceneMode> onLoad;

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

void OnSceneLoaded(Scene scene, LoadSceneMode mode)
{
  Debug.Log(string.Format("{0}, {1}", scene.name, mode.ToString()));
}
{% endhighlight %}

위의 코드는 event 의 접근 제한이 어디에 걸려있는지 알 수 있다. 자기 자신의 이벤트 대리자는 얼마든지 접근이 가능하지만, 외부에서 이벤트 대리자를 접근할 때는 대입 연산자는 불가능하고, 등록(+=) 하거나 취소(-=) 하는 연산자만 쓸 수 있다.

즉 이벤트 키워드는 인스턴스 외부에서 대리자를 보호하는 역할을 하며, 외부에서 이벤트 키워드가 붙은 대리자 자체를 이벤트를 전달받는 용도로만 쓰도록 한다.

## Serializable 한 이벤트 : UnityEvent

위에서 C# 에서 지원하는 Event, Delegate 문법을 알아보았다. 저 문법들만 잘 활용해도 깔끔하게 스크립팅이 가능하지만, Unity 시스템에서는 조금은 모자란 부분이 있다. 그래서 Unity 에서는 C# 의 Event, Delegate 기능을 따로 구현을 해서 지원한다. 구현을 클래스로 제공하는데 이름은 [UnityEvent](https://docs.unity3d.com/ScriptReference/Events.UnityEvent.html) 다.

스크립트에서 이벤트 사용은 거의 비슷하다. 런타임 내에서는 이벤트를 등록하거나, 제거할 수 있고 Invoke 메소드를 통해 이벤트를 알려주면 된다. 하지만 UnityEvent 는 스크립팅보다는 Hierarchy 시스템 내에서 빛을 발한다. UGUI 의 Button 컴포넌트를 아래 그림이 있다. 한번 살펴보자.

![inspector](/images/eventhandling-inspector.png){: .center-image }

일반적으로 버튼은 "눌렸을 때, 무언가 동작을 한다." 라고 생각을 할것이다. 그래서 동작을 이어주는 부분이 _OnClick()_ 이라고 쓰여있는 부분이다. _OnClick()_ 에 두개의 블록이 있다. 블록은 아래 +, - 버튼을 통해 없에거나 만들 수 있다. 그리고 각 블록의 역할은 게임 오브젝트의 컴포넌트의 메소드 하나를 연결하는 역할을 한다. 블록은 연결할 메소드의 갯수만큼 늘리고 줄이면 된다.

설정하는 방법은 간단하다. Hierarchy 내에서 하나의 게임오브젝트를 선택하고, 게임 오브젝트가 가지고 있는 컴포넌트 중의 메소드를 하나 선택한다. 그리고 파라미터가 있으면 간단하게 설정해주면 된다. 아래 그림과 같이 말이다.

![inspector](/images/eventhandling-inspector-select-method.png){: .center-image }

이렇게 메소드를 등록하면된다. 그런데 UnityEvent 에 등록할 수 있는 메소드의 제한이 있다. 타겟 게임 오브젝트와 자신의 게임 오브젝트의 관계가 고정되어야 하고, static 함수가 아니여야 하며, 무조건 public 으로 접근제한자가 설정되어 있어야 한다. static 함수가 아니여야 하는건 실제 컴포넌트의 메소드를 호출한다는 컨셉인것 같고, 접근제한자가 public 이여야 하는건 스크립트의 유연함을 위해 그런듯 하다.

그런데 사용하다보면 조금 의문이 드는점이 있다. [UnityEvent](https://docs.unity3d.com/ScriptReference/Events.UnityEvent.html) 에서 정의된 _AddListener/RemoveListener_ 와 인스펙터에서 설정해준 정보들이 다르게 취급되는 것처럼 보인다.

사실 UnityEvent 에서는 메소드 등록 정보를 두개로 나누어서 관리한다.

하나는 인스펙터에서 설정해준 persistant listner(지속성 리스너), 하나는 non-persistant listener(비지속성 리스너) 로 구분을 한다. 인스펙터에서 설정해준 값들은 지속성 리스너로 취급하며 런타임에서는 수정이 불가능하다. Unity 프로젝트안에 저장된(직렬화된) 데이터들이라서 런타임에서는 수정이 불가능 하기 때문이다.(에디터에서는 가능하다)

그리고 UnityEvent 클래스에 직접 정의된 _AddListener/RemoveListener_ 은 비지속성 리스너를 취급하는 메소드다. 이들은 런타임에서 등록, 제거가 가능하다. 하지만 지속되지 않는(저장되지 않는) 리스너로 위에서 설명한 C# event, delgate 문법과 같은 기능을 한다.

파라미터 설정도 사용자 마음대로 설정할수 있다. 자세한 설정 방법은 [UnityEvent](https://docs.unity3d.com/ScriptReference/Events.UnityEvent_1.html) 를 참조하면 된다.

## 실제 사용 사례 및 장단점

C# Delegate 문법은 정말 무궁무진하게 쓰인다. 특히 일시적인 루틴이 아닌 비동기 처리가 필요할 때 유용하게 쓸 수 있다. 아래 예시를 보자.

{% highlight c# lineos %}

int GetObjectCount()
{
  ..

  // 무조건 한번에 값을 반환해주어야 함.
}

void GetObjectCount(Action<int> getCount)
{
  ..

  // 실행시에 대리자를 호출할 수도 있고, 일정 시간이 흐른뒤에 대리자를 호출할 수도 있다.
}

{% endhighlight %}

Action 은 C# 라이브러리에서 미리 정해놓은 대리자 형식이다.([Action 링크](https://msdn.microsoft.com/ko-kr/library/018hxwa8.aspx))

가장 흔하게 대리자를 볼 수 있는 소스는 로그인 플랫폼 API 에 가장 많이 붙어있다. 대부분 네트워크 통신을 하기 때문에 당연히 비동기 처리에 대한 답이 필요하고, 가장 편한 수단으로 대리자를 뽑은 것이다.

{% highlight c# lineos %}
using System;

private Action<bool> loginSuccess;

public void Login(Action<bool> loginSuccess)
{
  this.loginSuccess = loginSuccess;

  Debug.Log("Login");

  StartCoroutine("getGoogle");
}

private IEnumerator getGoogle()
{
  WWW googleConnection = new WWW("https://www.google.com");

  yield return googleConnection;

  Debug.Log("getGoogle");

  if (loginSuccess != null) loginSuccess(string.IsNullOrEmpty(googleConnection.error));
}
{% endhighlight %}

위의 Login 메소드가 대표적인 예시다.

UnityEvent 빨리 게임 로직을 작업해야 할때나, UI 로직을 구성할 때 가장 많이 쓰인다. UGUI 의 많은 위젯들도 UnityEvent 를 사용하고 심지어 UI 전용 이벤트를 처리해주는 EventTrigger 라는 컴포넌트도 있을 정도로 UnityEvent 를 많이 활용한다.

게임 로직도 UnityEvent 로 구성하면 만들때는 쉽지만 UnityEvent 는 가독성이 상당히 안좋기 때문에 복잡한 게임 로직을 구성하면 나중에는 손댈수 없는 스파게티 코드도 아닌 덩어리가 만들어질 것이다. 하지만 간단한 게임 로직이나, 프로토타이핑에는 매우 적합하다. 그리고 개인적으로 제일 좋은 것은 이벤트를 연결하는 코드를 관리하지 않아서 좋다.

런타임 퍼포먼스에 대해에서는 이 글을 참고하라 : [Event Performance: C# vs UnityEvent(영문)](http://jacksondunstan.com/articles/3335)

위에서 말한 내용을 예제에서 확인하면 편리할 것이다. 아래 Github 링크를 올려놓았으니 확인해보길 바란다.

링크 : [Extended-Roll-a-Ball](https://github.com/hrmrzizon/Extended-Roll-a-Ball)

## 참조

- [MSDN 방법: 대리자 선언, 인스턴스화 및 사용](https://msdn.microsoft.com/ko-kr/library/ms173176.aspx)
- [MSDN C# Delegate](https://msdn.microsoft.com/ko-kr/library/ms173172.aspx)
- [MSDN C# Event](https://msdn.microsoft.com/ko-kr/library/awbftdfh.aspx)
- [Event Performance](http://jacksondunstan.com/articles/3335)
- [UnityEvent Manual](https://docs.unity3d.com/kr/current/Manual/UnityEvents.html)
