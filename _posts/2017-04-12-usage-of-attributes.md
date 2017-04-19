---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - try
---

C# 문법은 클래스, 구조체, 열거형, 멤버 변수, 메소드등 여러 타입에 표시를 하는 기능을 제공한다. 또한 일부 C# 에서 제공하는 기능 중에 정해준 표시를 붙이면 작동하는 기능들도 있다. 이 표시들을 C# 문법에서는 __Attribute__(속성) 라고 칭한다. 그리고 이 속성을 사용하여 Unity 에서는 많은 기능들을 제공한다. 아래 우리가 가장 많이 볼만한 속성을 사용한 예제가 있다.
<!-- more -->
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

## 사용자 정의 자료형 직렬화

Unity 는 위 예제에서 보다시피 C# 의 기본 자료형과 Unity 에서 지원하는 자료형들의 변수를 Inspector 에서 에디팅할 수 있게 지원한다. 아래 스크립트와 그림을 보자.

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

## CustomPropertyDrawer 를 이용하여 변수의 Inspector 바꾸기

#### 클래스를 사용하여 커스터마이징하기

보통 클래스나 구조체를 사용해 자료를 저장하는 경우는 꽤 많다. 그리고 데이터\가 많아지면 많아질 수록 넣어야할 변수는 많아지고 Inspector 창은 혼란의 도가니에 빠지게 된다. 아래와 같이 말이다.

![Inspector](/images/unity_support_inspector_3.png){: .center-image }

위의 예시는 조금 극단적이긴 하지만 변수가 6개씩만 넘어도 한눈에 보기에도 힘들고 편집하는데도 살짝 헷갈린다. 그리고 간단한 시스템이 아니면 대부분 꽤 많은 변수를 가지게 된다. 그래서 Unity 에서는 타입별로 Inpector 에서 보이는 에디팅 환경을 바꾸는 것을 지원한다. 위의 선언한 __SomeDataObject__ 를 이용하여 바꾸어보기로 하자.

우선 에디터 전용 스크립트를 만들어 주어야 한다. Unity 의 Project 창에서 아무 위치에나 _"Editor"_ 라는 이름으로 폴더를 만들어주고, 그안에 스크립트를 만들어주자. 아래 그림과 같이 말이다.

![Project-editor](/images/editor_code_location.png){: .center-image }

__SomeDataObject__ 를 그리는 에디터이니 __SomeDataObjectDrawer__ 로 이름을 지어주었다. 그리고 그 안의 내용을 아래와 같이 적어주자.

{% highlight c# lineos %}
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(SomeDataObject))]
public class SomeDataObjectDrawer : PropertyDrawer
{
  public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
  {
      return EditorGUI.GetPropertyHeight(property);
  }

  public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
  {
      EditorGUI.PropertyField(position, property, true);
  }
}
{% endhighlight %}

위 예제는 원래 나오는 방식과 똑같이 구현을 해놓은 예제다. 여기서 주목해야할 점은 두개다. __PropertyDrawer__ 클래스와 __CustomPropertyDrawer__ 속성이다. __PropertyDrawer__ 클래스는 Inspector 내에서 직접 그리는 클래스의 모체로써, Inspector 에서 보이는 변수의 모습을 바꾸려면 이 클래스를 상속받아 구현을 해놓아야 한다. __CustomPropertyDrawer__ 속성은 클래스나 속성 타입을 명시적으로 넣어주어 해당 타입의 변수들이 Inspector 에서 보이는 모습을 바꾸겠다는 속성이다. 위 예제를 보면 __CustomPropertyDrawer__ 속성에는 __SomeDataObject__ 를 넣어주어 __SomeDataObject__ 클래스의 모든 변수들을 __SomeDataObjectDrawer__ 안의 코드를 이용해 보여준다는 의미다. 그리고 __SomeDataObjectDrawer__ 클래스는 __PropertyDrawer__ 를 상속해 _GetPropertyHeight_ 메소드를 이용하여 높이값을 가져오고, _OnGUI_ 메소드를 사용하여 실제로 Inspector 창안에서 보이는 것을 구현한다. 위 코드에서는 기본적으로 제공하는 높이와, Unity 에서 사용하는 에디터 구현 코드를 사용해서 기존 에디터와 같은 방식으로 보일 것이다.

기본적인 구현 방법에 대해 알아보았으니 아래 그림처럼 구현해보자.

![Inspector](/images/unity_support_inspector_4.png){: .center-image }

아래에 구현 코드가 있다.

{% highlight c# lineos %}
const float numberWidth = 30;

public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
{
    // 왼쪽에 이름으로 나오는 라벨, 여기서는 변수 이름이 들어감.
    position = EditorGUI.PrefixLabel(position, label);

    float otherWidth = position.width - numberWidth * 2;

    // 각 위치별로 설정해줌.
    Rect nameRect = new Rect(position.x, position.y, otherWidth, position.height),
        numberRect = new Rect(position.x + otherWidth, position.y, numberWidth, position.height),
        rotateRect = new Rect(position.x + otherWidth + numberWidth, position.y, numberWidth, position.height);

    // 각 변수별로 Unity 에서 기본으로 지원하는 형식을 사용함.
    // 끝에 GUIContent.none 를 안넣어주면 이름이 표시되어 에디터에서 밀리게 나옴.
    EditorGUI.PropertyField(nameRect, property.FindPropertyRelative("someName"), GUIContent.none);
    EditorGUI.PropertyField(numberRect, property.FindPropertyRelative("someNumber"), GUIContent.none);
    EditorGUI.PropertyField(rotateRect, property.FindPropertyRelative("someYRotation"), GUIContent.none);
}
{% endhighlight %}

위 코드는 한 변수당 한줄이였던 방식에서 데이터를 한줄에 넣어주는 코드다. __EditorGUI.PrefixLabel__ 메소드를 통해 앞에 표시되는 이름을 보여주고, 숫자를 넣어주는 부분의 넓이를 확보하고 나머지 넓이를 문자열을 보여주는데 사용한다.

여기까지 클래스 변수가 Inspector 창에서 보이는 부분을 직접 커스터마이징 하는 방법에 대해서 알아보았다. 이 __PropertyDrawer__ 기능을 이용하여 타입별로 고정하는게 아닌 __Attribute__ 를 이용하여 필요한 부분만 바꾸는 방법도 있다.

#### 속성을 사용하여 커스터마이징하기

C# 문법은 __Enum__ 을 비트플래그로 사용하는 방법이 있다. 아래와 같이 말이다.

{% highlight c# lineos %}
[System.Flags]
public enum SomeEnumFlag
{
    Some    = 1 << 0,
    Any     = 1 << 1,
    Other   = 1 << 2,
}
{% endhighlight %}

__Enum__ 의 정의에다가 __System.Flags__ 를 붙여 사용하면 된다. 그런데 Unity 에서는 이 __Enum__ 을 황용하여 비트마스크를 보여주는 기능을 지원하지 않는다. 단지 한개의 아이템만 선택하는 기능만 지원한다. 그래서 Inspector 에서 비트 플래그를 사용하여 값을 설정하려면 직접 __PropertyDrawer__ 를 사용하여 에디터를 바꿔주어야 한다. 그래서 아래처럼 코드를 짜보았다.

{% highlight c# lineos %}
[CustomPropertyDrawer(typeof(SomeEnumFlag))]
public class SomeEnumFlagDrawer : PropertyDrawer
{
    public static Dictionary<Type, string[]> enumTypeNameDict = new Dictionary<Type, string[]>();

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EnumFlagAttribute attribute = this.attribute as EnumFlagAttribute;

        if (attribute != null)
        {
            string[] enumNames = null;

            if (!enumTypeNameDict.TryGetValue(attribute.enumType, out enumNames))
            {
                enumNames = Enum.GetNames(attribute.enumType);
                enumTypeNameDict.Add(attribute.enumType, enumNames);
            }

            if (enumNames != null && enumNames.Length > 0)
            {
                property.intValue = EditorGUI.MaskField(position, label, property.intValue, enumNames);
                return;
            }
        }

        EditorGUI.PropertyField(position, property);
    }
}
{% endhighlight %}

직접 실행시켜보면 알겠지만 저 코드는 잘 동작하지 않는다. 왜냐하면 __CustomPropertyDrawer__ 를 사용해서 바꿀 타입은 클래스들만 가능하기 때문이다. __SomeEnumFlag__ 는 __Enum__ 자료형이기 때문에 저 방식은 통하지 않는다. 이럴 때 __Attribute__ 를 직접 만들어 설정이 가능하다.

{% highlight c# lineos %}
using System;
using UnityEngine;

public class EnumFlagAttribute : PropertyAttribute
{
    public Type enumType;

    public EnumFlagAttribute() { }
}
{% endhighlight %}

위 코드는 속성을 직접 선언한 코드다. 중요한 점은 Unity 에서 지원하는 __PropertyAttribute__ 를 상속받아서 정의하였다는 점이다. __PropertyAttribute__ 를 사용해야만 Inspector 창에서 보이는 방식을 바꿀 수 있다. 위에서 만들어준 __Enum__ 비트 플래그 에디터 코드에 아래와 같이 연결시켜준다.

{% highlight c# lineos %}
[CustomPropertyDrawer(typeof(EnumFlagAttribute))]
public class SomeEnumFlagDrawer : PropertyDrawer { ... }
{% endhighlight %}

그 다음 해당 속성을 변수에 붙여주면 Inspector 에서 아래 그림과 같이 보일것이다.

![Inspector](/images/unity_support_inspector_5.png){: .center-image }

클래스 또는 속성별로 변수별 Inspector 에디터를 바꿔보는 __PropertyDrawer__ 설정 방법에 대해서 알아보았다.

여태까지 설명했던 기능들은 전부 __Attribute__ 를 사용하여 지원한다. 그리고 설명하지 않은 __Attribute__ 문법을 사용하는 기능들도 엄~~청 많다. __Attribute__ 에 대해 이해를 하고 있으면 앞으로의 추가적인 기능들을 사용하는데 많은 도움이 될것이다.

## 참조

- [C# Attribute Usage](https://msdn.microsoft.com/ko-kr/library/mt653982.aspx)
- [Unity Custom Attribute](https://docs.unity3d.com/ScriptReference/PropertyDrawer.html)
- [PropertyDrawer 번역 네이버 블로그](http://blog.naver.com/PostView.nhn?blogId=hammerimpact&logNo=220775187161&redirect=Dlog&widgetTypeCall=true)
- [Set of Unity Attribute](http://www.tallior.com/unity-attributes/)
