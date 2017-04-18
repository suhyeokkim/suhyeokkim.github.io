---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: false
categories:
  - unity
  - try
---

## Unity 의 데이터 저장 시스템 : Serialization

<!-- 뭔가 서론을 써주어야함. -->

<!--
C# 문법은 클래스, 구조체, 열거형, 멤버 변수, 메소드등 여러 타입에 표시를 하는 기능을 제공한다. 또한 일부 C# 에서 제공하는 기능 중에 정해준 표시를 붙이면 작동하는 기능들도 있다. 이 표시들을 C# 문법에서는 __Attribute__(속성) 라고 칭한다. 그리고 이 속성을 사용하여 Unity 에서는 많은 기능들을 제공한다. 아래 우리가 가장 많이 볼만한 속성을 사용한 예제가 있다.
-->

{% highlight c# lineos %}
// Unity 시스템에 데이터를 직렬화해 멤버변수 초기값을 지정한다.
[UnityEngine.SerializeField]
public int limitCount;

// 직렬화를 못하게 한다.
[System.NonSerailized]
public int gameCount;
{% endhighlight %}

위의 예제에서 Unity 의 변수 직렬화를 다룰 수 있는 속성을 사용한 예제를 볼 수 있다. 원래 Unity 스크립팅 시스템에서는 따로 멤버 직렬화에 대한 속성을 지정하지 않으면 접근 제한자(public, protected, private) 에 따라 직렬화를 할지 말지 결정했다. 하지만 접근 제한자로만 Unity 에서는 멤버 변수 직렬화를 __Attribute__ 문법을 사용해 Unity 전용 속성을 만들어 제어를 할 수 있도록 해두었다.

클래스 멤버 변수 직렬화를 제어하는 속성은 세개가 있다. __UnityEngine.SerializeField__ 와 __UnityEngine.HideInInspector__ 와 __System.NonSerailized__ 이 세개다. __UnityEngine.SerializeField__ 는 클래스 멤버 변수의 데이터를 직렬화 해주어 인스턴스가 생성되었을 떄 Unity 시스템에서 직렬화한 데이터로 초기화 시켜주는 속성이고, __UnityEngine.HideInInspector__ 는 이전에 직렬화된 데이터와의 링크를 끊어 일시적으로 직렬화를 사용한 초기화를 막고 Inspector 에서도 안보이게 해준다. __System.NonSerailized__ 는 해당 멤버 변수의 직렬화를 아예 막는 속성이다.

| SerializeField | | HideInInspector | | NonSerailized |
| :------: | :------: | :------: | :------: | :------: |
| 변수 직렬화를 해주는 __Attribute__ | | 직렬화된 데이터를 숨기는 __Attribute__ | | 변수 직렬화를 막는 __Attribute__ |
| | | | | | |

위 세개의 속성들로 Unity 직렬화 시스템을 제어할 수 있다. __UnityEngine.SerializeField__ 는 직렬화된 데이터가 필요할 때, __System.NonSerailized__ 는 직렬화된 데이터가 전혀 필요 없을 때, __UnityEngine.HideInInspector__ 는 개발 도중에 잠시 직렬화된 데이터와 연결을 끊을 때 사용한다.

필자는 확실한 것을 지향하기 때문에 [__UnityEngine.HideInInspector__](https://docs.unity3d.com/kr/current/ScriptReference/HideInInspector.html) 를 잘 사용하진 않는다. 링크를 타고 들어가면 나오지만 정확한 행동의 정의되지 않았다. 단지 숨기기만 하는건지, 직렬화된 데이터를 없에는건지 설명이 명확하게 되어있지 않다. 또한 현재쓰는 Unity 5.5.2 버젼으로 테스트를 해보면 __UnityEngine.HideInInspector__ 가 붙은 직렬화 데이터가 초기화 되는 경우가 있다.

## 클래스, 구조체 직렬화

Unity 는 C# 의 기본 자료형과 Unity 에서 지원하는 자료형들의 변수를 Inspector 에서 에디팅할 수 있게 지원한다. 아래 스크립트와 그림을 보자.

{% highlight c# lineos %}
public class SomeScript : MonoBehaviour
{
    [SerializeField]
    private float someNumber;

    [SerializeField]
    private Color someColor;

    [SerializeField]
    private Vector3 someVector;

    [SerializeField]
    public AnimationCurve someCurve;

    ...
}
{% endhighlight %}

SomeScript 가 붙은 GameObject 의 Inspector 창에 아래와 같은 모습이 보일것이다.

![Inspector](/images/unity_support_inspector_1.png){: .center-image }

위 그림과 같이 Unity 에서는 기본 자료형과 Unity 에서 지원하는 자료형을 Inspector 에서 에디팅하는 것을 지원한다. 하지만 클래스, 구조체 같은 사용자 정의 자료형은 경우가 조금 다르다. 무작정 __SerializeField__ 속성을 붙인다고 되지는 않는다.

{% highlight c# lineos %}

public class SomeDataObject
{
    public string someName;
    public int someNumber;
    public float someYRotation;
}

public class SomeScript : MonoBehaviour
{
    ...

    [SerializeField]
    private SomeDataObject someObject;
}

{% endhighlight %}

이 코드를 직접 실행시켜보면 알겠지만 이렇게 해봤자 Inspector 에서는 별 변화가 없다. __SomeDataObject__ 같이 __MonoBehaviour__ 를 상속받지 않은 사용자 정의 자료형들은 Inspector 에서 에디팅을 가능하게 하고, 저장을 하려면 클래스에 직렬화(__Serializable__) 하다는 속성을 붙여주어야 한다.

{% highlight c# lineos %}
[System.Serializable]
public class SomeDataObject { ... }
{% endhighlight %}

위와 같이 속성 하나만 붙여주면 Inspector 에서 에디팅이 가능하고 직렬화가 되어 자동으로 초기화가 가능해진다. 아래 그림과 같이 보일 것이다.

![Inspector](/images/unity_support_inspector_2.png){: .center-image }


## 참조

- [Unity Script-Serialization](https://docs.unity3d.com/kr/current/Manual/script-Serialization.html)
