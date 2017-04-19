---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - try
---

CustomPropertyDrawer 를 사용할 때 필드에 설정한 __Tooltip__ 정보가 전달이 안될 때가 있다. 이때는 아래와 같이 하면 된다.

{% highlight c# lineos %}
public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
{
    GUIContent content = EditorGUI.BeginProperty(position, label, property);

    // label 대신 content 를 에디터 코드에 넣어줌.

    EditorGUI.EndProperty();
}
{% endhighlight %}

OnGUI 를 통해 넘어오는 __label__ 파라미터에는 단지 텍스트만 들어가있어 조금 더 살펴보니 위의 방법처럼 해당 프로퍼티의 __GUIContent__ 를 가져오는 방법이 있었다. 저 반환된 __GUIContent__ 는 어디에서도 사용가능하니 유용하게 쓰일듯하다.
