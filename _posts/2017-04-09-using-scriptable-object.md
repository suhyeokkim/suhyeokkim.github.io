---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
---

2년전 Unity 로 모바일 게임 개발을 시작했었다. 학생 시절 간단하게 게임을 만든적은 있었지만 Unity 로 게임을 만들어본 적은 한번도 없었기에 매우 어려운 도전이였다. 그래서 Unity 시스템에 대해 간단히 알고 개발을 시작했었는데 당시에는 ScriptableObject 의 기능을 모르고 있던터라 단순히 Prefab 만으로 데이터를 저장하고 있었다.

![Subway suffer](/images/subwaysurfer.png){: .center-image }

당시 만든 게임은 3D 러닝 게임이였는데, 서브웨이 서퍼과 비슷한 방식의 게임이였다. 핵심은 어떻게 맵을 계속 나타나게 하느냐 였는데, 나는 단순하게 플레이어의 위치에 따라 맵을 계속 이어붙였다.

![runtime map](/images/map_example_0.png){: .center-image }

Map 은 Prefab 단위로 구성되어 있었는데, Map Prefab 에는 플레이어가 지나갈 길의 정보, 3D 메쉬 정보가 있었다. 그리고 맵 종류별로 풀링을 하여 활용했었다.

![map pooling](/images/map_example_1.png){: .center-image }

여기서 한가지 아쉬운게 있다면 Map Prefab 별로 모두 길 정보를 가지고 있는게 아쉬웠다. 프리팹은 보이는 정보만 가지고 길 정보는 따로 존재해  참조하는 방식이 조금 더 나았을 것이다. 종류 별로 반복되는 길 정보가 많았기 때문에 더욱 아쉬웠다.

![map refer to road data](/images/map_example_2.png){: .center-image }

위와 같이 길 정보는 따로 존재하고 맵이 길 정보를 참조하는 방식으로 말이다. 하지만 위와 같은 방식을 고안하더라도 실제로 구현할 방법을 몰랐기 때문에 방치했었다. 하지만 지금은 독립적으로 존재하는 데이터 에셋을 만드는 방법을 알고 있다. 그건 바로 ScriptableObject 라는 에셋 타입이다.
<!-- more -->
## 정적인 에셋 타입 : ScriptableObject

ScriptableObject 는 Inspector 에 존재하는 데이터 에셋의 종류 중 하나다. Prefab 처럼 그 자체를 복사할 수 없고, 단지 독립적으로 존재한다. 그래서 ScriptableObject 를 참조해서 데이터에 접근할 수 있다. 이름처럼 스크립트에서 ScriptableObject 라는 클래스를 상속받아 활용하며 데이터 직렬화를 지원하기 때문에 컴포넌트 스크립팅 처럼 데이터를 저장하여 사용가능하다. 시작할 때 언급한 길 정보를 ScriptableObject 로 직접 만들어 보았다.

{% highlight c# lineos %}
using UnityEngine;

[CreateAssetMenu(fileName = "RoadData", menuName = "Examples/RoadData")]
public class RoadDataOjbect : ScriptableObject
{
  [SerializeField]
  private Vector3[] roadPositionArray;

  public int Length { get { return roadPositionArray.Length; } }

  public Vector3 GetPositionAt(int idx)
  {
    return roadPositionArray[idx];
  }
}
{% endhighlight %}

위의 구현을 보면 필요한 데이터(위에서는 위치정보)를 저장하기만 한다. 스크립팅 방식은 저장할 데이터를 선언만 해주고, 그 데이터를 관리하는 코드만 짜주면 된다. 컴포넌트 스크립팅과 조금 다른점은 직접 행동하는 개체가 아니기 때문에 실제 게임 로직은 제외해서 코딩을 하게 된다.

하지만 ScriptableObject 의 의의는 스크립팅 방식이 아니라, 독립적으로 존재하는 것에 의미를 더 부여한다. 정확히 정의하자면 "독립적으로 존재하는 데이터의 집합 에셋" 이라고 할 수 있다. 그래서 독립적으로 존재하기 위해 파일로 직접 만들어주는 코드가 필요하다.

그 코드가 클래스 선언위의 [CreateAssetMenu](https://docs.unity3d.com/ScriptReference/CreateAssetMenuAttribute.html) 라는 속성이다. MonoBehaviour 를 활용한 스크립트는 컴포넌트로 취급되기 때문에 GameObject 에 붙이기만 하면 자연스럽게 사용할 수 있다. 하지만 ScriptableObject 는 독립적으로 존재하기 때문에 생성하는 코드를 만들어 주어야 한다. 저 속성을 붙이면 아래 그림처럼 메뉴에 만드는 코드가 추가된다.

![make scriptableObject](/images/make_scriptableobject.png){: .center-image }

위의 그림처럼 메뉴를 선택하면 아래 그림과 같이 스크립트를 만들때와 동일하게 이름을 설정하고 파일을 만들 수 있다.

![make scriptableObject inspector](/images/make_scriptableobject_inspector.png){: .center-image }

위 예제에서는 ScriptableObject 를 단순히 데이터 자체만 저장하는 용도로 쓰는 예시를 보여주었다. 단순 데이터 저장 방식으로도 많이 쓰이지만 이를 프로젝트 내의 에셋을 연결시켜주는 용도로도 사용할 수 있다. 아래 그림처럼 말이다.

![set of asset or data](/images/set_scriptableobject.png){: .center-image }

ScriptableObject 에 단순 데이터, 관련된 애셋들을 묶어 관리하면 조금더 효율적으로 관리할 수 있다.

[UnityExample](https://github.com/hrmrzizon/UnityExample) 에 위에서 나온 예들을 적용시킨 예제가 있으니 살펴보길 바란다.

## 참조

- [Untiy Serialize](https://docs.unity3d.com/kr/current/Manual/script-Serialization.html)
- [Unity ScriptableObject](https://docs.unity3d.com/kr/current/Manual/class-ScriptableObject.html)
- [네이버 블로그](http://blog.naver.com/PostView.nhn?blogId=hammerimpact&logNo=220770261760)
- [Unity ScriptableObject Guideline](https://unity3d.com/kr/learn/tutorials/modules/beginner/live-training-archive/scriptable-objects)
