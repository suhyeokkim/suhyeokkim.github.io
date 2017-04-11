---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: false
categories:
  - unity
  - try
---

## 클래스, 변수에 태그를 붙이다 : Attribute

C# 문법은 클래스, 구조체, 열거형, 멤버 변수, 메소드등 여러 타입에 표시를 하는 기능을 제공한다. 또한 일부 C# 에서 제공하는 기능 중에 정해준 표시를 붙이면 작동하는 기능들도 있다. 이 표시들을 C# 문법에서는 __Attribute__ 라고 칭한다. 그리고 이 __Attribute__ 를 사용하여 Unity 에서는 많은 기능들을 제공한다. 아래 우리가 가장 많이 볼만한 __Attribute__ 를 사용한 예제가 있다.

{% highlight c# lineos %}
// Unity 시스템에 데이터를 직렬화해 멤버변수 초기값을 지정한다.
[UnityEngine.SerializeField]
public int limitCount;

// 직렬화를 못하게 한다.
[System.NonSerailized]
public int gameCount;

// 이 클래스의 인스턴스를 직렬화를 가능하게 한다.
[System.Serializable]
public class Data { }

// 직렬화 마크가 추가된 클래스를 변수를 선언하면 데이터를 직렬화해서 저장한다.
[UnityEngine.SerializeField]
public Data dataObject;
{% endhighlight %}

위의 예제에서 Unity 의 변수 직렬화를 다룰 수 있는 __Attribute__ 를 사용한 예제를 볼 수 있다. 원래 Unity 스크립팅 시스템에서는 따로 멤버 직렬화에 대한 __Attribute__ 를 지정하지 않으면 접근 제한자(public, protected, private) 에 따라 직렬화를 할지 말지 결정했다. 하지만 접근 제한자로만 Unity 에서는 멤버 변수 직렬화를 __Attribute__ 문법을 사용해 Unity 전용 __Attribute__ 를 만들어 제어를 할 수 있도록 해두었다.

클래스 멤버 변수 직렬화를 제어하는 __Attribute__ 는 두개가 있다. __UnityEngine.SerializeField__ 와 __System.NonSerailized__ 이 두개다. 영어를 조금만 해석할줄 알면 알겠지만 __UnityEngine.SerializeField__ 는 클래스 멤버 변수의 데이터를 직렬화 해주어 인스턴스가 생성되었을 떄 Unity 시스템에서 직렬화한 데이터로 초기화 시켜주는 __Attribute__ 이고, __System.NonSerailized__ 는 해당 멤버 변수의 직렬화를 아예 막는 __Attribute__ 다.

| SerializeField | | NonSerailized |
| :------: | :------: | :------: |
| 변수 직렬화를 해주는 __Attribute__ | | 변수 직렬화를 막는 __Attribute__ |
| | | | |

Unity 는 위 예제에서 본것처럼 여러 기능들을 __Attribute__ 를 통해 제공한다. 제공하는 기능 중에 유용하게 쓰일만한 기능들을 한번 살펴보자.

-----------

여기까지 씀
내용 보강 필요

-----------

## 변수 인스펙터 제어하기

SpaceAttribute
HeaderAttribute
RangeAttribute
TooltipAttribute
TextAreaAttribute

## 변수 직렬화 제어하기

SerializeField, HideInInspector
Serializable, NonSerailized

## PropertyAttribute 로 변수의 인스펙터 바꾸기

데이터 타입을 자체의 PropertyDrawer 을 설정할 수 도 있고, 일정 어트리뷰트를 붙여서 설정할 수도 있다.

PropertyAttribute
PropertyDrawer


## 마지막

Unity 는 다양한 __Attribute__ 를 통해 여러 기능들을 지원한다. 여러 __Attribute__ 를 살펴보면 스크립팅에 사용되는 여러가지 기능들에 대해 알 수 있을 것이다. [Unity Attribute 정리 글](http://www.tallior.com/unity-attributes/) 을 보면 여러가지의 __Attribute__ 를 정리해 놓은 것을 볼 수 있다.


## 참조

- [C# Attribute Usage](https://msdn.microsoft.com/ko-kr/library/mt653982.aspx)
- [Unity Custom Attribute](https://docs.unity3d.com/ScriptReference/PropertyDrawer.html)
- [PropertyDrawer 번역 네이버 블로그](http://blog.naver.com/PostView.nhn?blogId=hammerimpact&logNo=220775187161&redirect=Dlog&widgetTypeCall=true)
- [Set of Unity Attribute](http://www.tallior.com/unity-attributes/)
