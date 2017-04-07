---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: true
categories:
  - unity
  - try
---

## 이름으로 메소드를 호출하다. SendMessage

Unity 런타임 시스템에서는 Unity 자체의 캐시 시스템을 이용하여 컴포넌트의 메소드를 문자열로 찾아 호출해주는 기능을 가지고 있다. 그중 하나는 __GameObject__ 와 [__Component__](https://docs.unity3d.com/ScriptReference/Component.html) 클래스에 존재하는 [__SendMessage__](https://docs.unity3d.com/kr/current/ScriptReference/GameObject.SendMessage.html) 라는 메소드다. 아래와 같이 사용을 할 수 있다.

{% highlight c# lineos %}

void OnEnable()
{
  SendMessage("DoSomething");
}

void DoSomething()
{
  Debug.Log("Do something!");
}

{% endhighlight %}

OnEnable 에서 해당 컴포넌트의 DoSomething 이라는 메소드를 찾아 호출하는 SendMessage 메소드를 호출하고, 아마 DoSomething 메소드가 호출되면서 로그가 출력될 것이다.

Unity 에서 메세징 방식의 대표적인 사용사례는 컴포넌트 스크립팅을 할 때 항상 볼 수 있는 Start, Update 등 [MonoBehaviour](https://docs.unity3d.com/ScriptReference/MonoBehaviour.html) 의 여러 메시지 콜백들이다. 저 메시지 콜백들을 통해 스크립트 컴포넌트는 여러 상태를 알 수 있다.

또한 __AnimationClip__ 을 사용할때 메세지 이벤트를 넣어서 사용할 수 있다. 애니메이션의 특정 프레임에 메시지 이벤트를 만들어 같은 게임오브젝트에 붙어있는 스크립트들에게 메시지를 던져준다. [UnityExample](https://github.com/hrmrzizon/UnityExample) 프로젝트의 MessageScene 의 ShakeCube 를 확인하라.

## 메시지 방식의 사실, 장단점

지금도 많은 사람들이 SendMessage 는 __"매우 느리다"__ 라는 생각을 하며 사용한다. 하지만 __"매우 느리다"__ 의 근거가 될만한 이유는 C# Reflection 기능을 __"실시간"__ 으로 사용하는 것에 있다. 이를 반박하자면

> GameObject 가 생성될 시에 각 컴포넌트별로 C# 리플렉션 기능을 사용해 메소드들의 위치와 이름을 함께 저장하여 가지고 있는다. 그리고 오브젝트가 파괴될 때까지 이 캐시 데이터를 저장해놓고 쓴다.

위의 문단의 내용이 사실이라면 __"매우 느리다"__ 의 근거는 없다. Unity 시스템에서 사용하는 기능이 그렇게 느릴리는 없다. ([유니티가 당신에게 알려주지 않는 것들](https://www.slideshare.net/MrDustinLee/ss-27739454) : 43 ~ 47쪽)

언제나 장점이 있으면 단점도 있다. 이 메시징 방식은 타입에 상관없이 문자열 하나로 메소드 호출이 가능하다는(Typeless call) 강력한 장점을 가지고 있다. 하지만 단점도 고려하고 사용해야 한다.

#### 1. 사용시 검색 시간을 고려한다.

직관적으로 생각해도 문자열 검색에 대한 비용이 있으니 매 프레임마다 호출해주거나 빈번히 사용이 일어날 때는 사용을 지양해야 한다.

#### 2. 컴포넌트 성성 타이밍에 C# Reflection 기능을 사용해 메소드 데이터를 생성한다. 이 때 부하가 발생한다.

퍼포먼스가 필요한 게임에서는 __GameObject__ 의 생성은 되도록 피하고, 모든 오브젝트를 가장 처음에 로드 후 재활용해서 사용한다.

#### 3. 접근 제한자에 상관없이 호출해주기 때문에 객체 캡슐화에 안좋은 영향을 미친다.

OOP(객체지향프로그래밍) 에서는 접근 제한자를 통해 외부에 노출시킬 메소드, 안에서 숨겨야할 메소드를 설정한다. 하지만 Unity 메시징 방식은 접근 제한자를 무시하기 때문에 OOP 원칙에 따라 프로그래밍을 할 프로그래머에게 모호한 선택을 요구한다.

#### 4. 레거시 시스템이 될 가능성이 있다.

[UGUI](https://bitbucket.org/Unity-Technologies/ui) 가 4.6 버젼에서 추가되면서 Unity 에서는 UnityEngine.Events 라는 기능도 추가되었다. 이 네임스페이스 안에는 UnityEvent 에 대한 구현도 있고, 현재 메시지 방식을 대체할 수 있는 EventSystem 이라는 시스템의 구현도 되어 있다. UGUI 에서는 UnityEngine.Events 안의 기능들을 적극 사용해 구현을 했다.

이를 통해 알 수 있는 점은 현재 기능에 대한 최적화는 가능성이 있으나, 더 이상의 기능 추가는 기대하기 어렵다. 즉 Animation 컴포넌트와 같이 기능 확장이 멈추어 새로 생기는 시스템과는 점점 멀어질 가능성이 높다.

메시징 방식을 사용할 때는 위 항목들을 명심하고 사용하길 바란다.

예제 : [UnityExample](https://github.com/hrmrzizon/UnityExample)

## 참조

- [Unity 메시지 시스템](https://docs.unity3d.com/kr/current/Manual/MessagingSystem.html)
- [GameDev HowToMessage](http://gamedev.stackexchange.com/questions/120327/how-to-send-an-interface-message)
- [유니티가 당신에게 알려주지 않는 것들](https://www.slideshare.net/MrDustinLee/ss-27739454)
