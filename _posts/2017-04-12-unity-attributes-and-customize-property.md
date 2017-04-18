---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: false
categories:
  - unity
  - try
---

C# 문법은 클래스, 구조체, 열거형, 멤버 변수, 메소드등 여러 타입에 표시를 하는 기능을 제공한다. 또한 일부 C# 에서 제공하는 기능 중에 정해준 표시를 붙이면 작동하는 기능들도 있다. 이 표시들을 C# 문법에서는 __Attribute__(속성) 라고 칭한다. 그리고 이 속성을 사용하여 Unity 에서는 많은 기능들을 제공한다. 아래 우리가 가장 많이 볼만한 속성을 사용한 예제가 있다.

## CustomPropertyDrawer 를 이용하여 변수의 Inspector 바꾸기

보통 클래스나 구조체를 사용해 자료를 저장하는 경우는 꽤 많다. 그리고 데이터가 많아지면 많아질 수록 넣어야할 변수는 많아지고 Inspector 창은 혼란의 도가니에 빠지게 된다. 아래와 같이 말이다.

![Inspector](/images/unity_support_inspector_3.png){: .center-image }

위의 예시는 조금 극단적이긴 하지만 변수가 6개씩만 넘어도 한눈에 보기에도 힘들고 편집하는데도 살짝 헷갈린다. 그리고 간단한 시스템이 아니면 대부분 꽤 많은 변수를 가지게 된다. 그래서 Unity 에서는 타입별로 Inpector 에서 보이는 에디팅 환경을 바꾸는 것을 지원한다.

{% highlight c# lineos %}
[CustomPropertyDrawer(typeof(SomeDataObject))]
public class SomeDataObjectDrawer : PropertyDrawer
{
    const float numberWidth = 30;

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);

        position = EditorGUI.PrefixLabel(position, GUIUtility.GetControlID(FocusType.Passive), label);

        float otherWidth = position.width - numberWidth * 2;

        Rect nameRect = new Rect(position.x, position.y, otherWidth, position.height),
            numberRect = new Rect(position.x + otherWidth, position.y, numberWidth, position.height),
            rotateRect = new Rect(position.x + otherWidth + numberWidth, position.y, numberWidth, position.height);

        EditorGUI.PropertyField(nameRect, property.FindPropertyRelative("someName"), GUIContent.none);
        EditorGUI.PropertyField(numberRect, property.FindPropertyRelative("someNumber"), GUIContent.none);
        EditorGUI.PropertyField(rotateRect, property.FindPropertyRelative("someYRotation"), GUIContent.none);

        EditorGUI.EndProperty();
    }
}
{% endhighlight %}


-----

여기까지씀
Attribute 도 사용해야함

-----

## 변수 인스펙터 제어하기

SpaceAttribute
HeaderAttribute
RangeAttribute
TooltipAttribute
TextAreaAttribute

## 참조

- [C# Attribute Usage](https://msdn.microsoft.com/ko-kr/library/mt653982.aspx)
- [Unity Custom Attribute](https://docs.unity3d.com/ScriptReference/PropertyDrawer.html)
- [PropertyDrawer 번역 네이버 블로그](http://blog.naver.com/PostView.nhn?blogId=hammerimpact&logNo=220775187161&redirect=Dlog&widgetTypeCall=true)
- [Set of Unity Attribute](http://www.tallior.com/unity-attributes/)
