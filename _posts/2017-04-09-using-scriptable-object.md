---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: true
categories:
  - unity
  - try
---

2년전 Unity 로 모바일 게임 개발을 시작했었다. 학생 시절 간단하게 게임을 만든적은 있었지만 Unity 로 게임을 만들어본 적은 한번도 없었기에 매우 어려운 도전이였다. 그래서 Unity 시스템에 대해 간단히 알고 개발을 시작했었는데 당시에는 ScriptableObject 의 기능을 모르고 있던터라 단순히 Prefab 만으로 데이터를 저장하고 있었다.

![Subway suffer](/images/subwaysurfer.png){: .center-image }

당시 만든 게임은 3D 러닝 게임이였는데, 서브웨이 서퍼과 비슷한 방식의 게임이였다. 핵심은 어떻게 맵을 계속 나타나게 하느냐 였는데, 나는 단순하게 플레이어의 위치에 따라 맵을 계속 이어붙였다.

![runtime map](/images/map_example_0.png){: .center-image }

Map 은 Prefab 단위로 구성되어 있었는데, Map Prefab 에는 플레이어가 지나갈 길의 정보, 3D 메쉬 정보가 있었다. 그리고 맵 종류별로 풀링을 하여 활용했었다.

![map pooling](/images/map_example_1.png){: .center-image }

여기서 한가지 아쉬운게 있다면 Map Prefab 별로 모두 길 정보를 가지고 있는게 아쉬웠다. 프리팹은 보이는 정보만 가지고 길 정보는 따로 존재해  참조하는 방식이 조금 더 나았을 것이다. 또한 종류 별로 반복되는 길 정보가 많았기 때문에 더욱 아쉬웠다.

![map refer to road data](/images/map_example_2.png){: .center-image }

위와 같이 길 정보는 따로 존재하고 맵이 길 정보를 참조하는 방식으로 말이다. 하지만 위와 같은 방식을 고안하더라도 실제로 구현할 방법을 몰랐기 때문에 방치했었다. 하지만 지금은 독립적으로 존재하는 데이터 에셋을 만드는 방법을 알고 있다. 그건 바로 ScriptableObject 라는 에셋 타입이다.

## 정적인 에셋 타입 : ScriptableObject

ScriptableObject 는 Inspector 에 존재하는 데이터 에셋의 종류 중 하나다. Prefabrication 처럼 그 자체를 복사할 수 없고, Hierarchy 에서 참조해서 데이터를 참조할 수는 있다. 이름에 걸맞게 스크립트에서 ScriptableObject 라는 클래스를 상속받아 사용가능하며 MonoBehaviour 를 상속받는 스크립트처럼 Serialize 할 데이터를 지정해 저장할 수 있다. 시작할 때 언급한 길 정보를 ScriptableObject 로 직접 만들어 보았다.

{% highlight c# lineos %}

using UnityEngine;

/\*
  RoadDataOjbect.cs
\*/

[CreateAssetMenu(fileName = "RoadData", menuName = "Scriptable/RoadData")]
public class RoadDataOjbect : ScriptableObject
{
  [SerializeField]
  private Vector3[] roadPositionArray;

  public int length { get { return roadPositionArray.Length; } }

  public Vector3 GetPositionAt(int idx)
  {
    return roadPositionArray[idx];
  }
}

{% endhighlight %}

위의 구현을 보면 보통 사용하는 MonoBehaviour 를 사용한 컴포넌트 스크립팅 방식과 크게 차이가 없어 보인다. 데이터 직렬화를 이용해 멤버 변수를 초기화하는 방식은 같다. 하지만 ScriptableObject 는 상속받은 객체의 직렬화 데이터만 가지고 독립적으로 존재하는 애셋이기 때문에 취급과 여러 사용방법은 조금 다른면이 있다.

가장 다른 점 하나를 뽑자면 클래스 선언위의 [CreateAssetMenu](https://docs.unity3d.com/ScriptReference/CreateAssetMenuAttribute.html) 라는 속성이다. MonoBehaviour 를 활용한 스크립트는 컴포넌트로 취급되기 때문에 GameObject 에 붙이기만 하면 자연스럽게 사용할 수 있다. 하지만 ScriptableObject 는 독립적으로 존재하기 때문에 생성하는 코드를 만들어 주어야 한다. 그래서 필요한 코드가 [CreateAssetMenu](https://docs.unity3d.com/ScriptReference/CreateAssetMenuAttribute.html) 속성이다. 저 속성을 붙이면 아래 그림처럼 메뉴에 만드는 코드가 추가된다.

![make scriptableObject](/images/make_scriptableobject.png){: .center-image }

위의 그림처럼 메뉴를 선택하면 아래 그림과 같이 스크립트를 만들때와 동일하게 이름을 설정하고 파일을 만들 수 있다.

![make scriptableObject inspector](/images/make_scriptableobject_inspector.png){: .center-image }

이렇게 말이다. [UnityExample](https://github.com/hrmrzizon/UnityExample) 에 이 코드를 적용시킨 예제가 있으니 살펴보길 바란다.

## 쓰임새 및 장단점

ScriptableObject 는 보통 위와같이 단순히 데이터만 가지고 있는 용도로 많이 쓰인다. 대표적으로 상점의 품목 데이터나, 위에서 예시로 들은 길 데이터와 같이 말이다. 또한 프로젝트 내에서 에셋들을 이어주는 중간 연결체로도 사용이 가능하다.

![set of asset or data](/images/set_scriptableobject.png){: .center-image }

에셋의 집합 역할을 해주는 중간 연결체는 에셋 번들을 사용하면 유용하게 사용할 수 있다.

장점 : 프리팹과 데이터를 분리할 수 있다. 에디터 코드까지 사용자가 직접 만들어야 한다.
단점 : 에디터 코드까지 사용자가 직접 만들어야 한다.

## 참조

- [Untiy Serialize](https://docs.unity3d.com/kr/current/Manual/script-Serialization.html)
- [Unity ScriptableObject](https://docs.unity3d.com/kr/current/Manual/class-ScriptableObject.html)
- [네이버 블로그](http://blog.naver.com/PostView.nhn?blogId=hammerimpact&logNo=220770261760)
- [Unity ScriptableObject Guideline](https://unity3d.com/kr/learn/tutorials/modules/beginner/live-training-archive/scriptable-objects)
