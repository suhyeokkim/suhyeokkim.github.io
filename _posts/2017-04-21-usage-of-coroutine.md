---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - c#
---

Unity 는 코루틴이라는 괴상한(?) 코딩 방식을 지원한다. 맨 처음에 발견했을 때는 Synchronize 한 코딩 방식에 익숙해져 있어 상당히 낯설고 적응이 안됐다. 하지만 응용 범위를 늘려가다보니 상당히 편한 코딩 방식이라는 것을 깨닳았다. 한번 코루틴에 대해 알아보자.

<!-- more -->

## Coroutine 사용하기

아래 예제를 보자. 몇초를 기다리는 로직을 코루틴을 사용해 구현했다.

{% highlight c# lineos %}
void Awake()
{
    StartCoroutine("Wait3Second");
}

IEnumerator Wait3Second()
{
    Debug.Log("Start.");
    yield return new WaitForSecond(3f);
    Debug.Log("After 3 second.");
}

void Update()
{
    if (Input.GetKeyDown(KeyCode.Space))
        StopCoroutine("Wait3Second");
}
{% endhighlight %}

시작 후 3초를 기다리는 간단한 코드다. 이 코드는 시작할 때 로그가 출력되고, 3초가 지난 후에 로그를 출력한다. 그리고 3초가 지가가기 전에 스페이스바를 누르면 실행하던 코루틴을 취소한다. __StartCoroutine__ 으로 코루틴 함수를 실행하면 코드에서 _yield return_ 구문이 나오기 전까지 실행하다가 _yield return_ 에서 반환하는 데이터에 따라 기다리기를 끝날때까지 반복한다. 아래 그림을 보면 이해가 쉬울 것 이다.

![coroutine execute](/images/common_coroutine_execute.png){: .center-image }

코루틴의 동작을 매우 간단하게 표현한 그림이다. 그런데 코루틴은 위 예제에서 호출한 방식 말고도 다른 방식으로 제어가 가능하다. 아래 예제를 살펴보자.

{% highlight c# lineos %}
Coroutine coroutine;
IEnumerator enumerator;

IEnumerator Wait(int num)
{
    float startTime = Time.time;
    print("Wait Start: " + startTime + ", number: " + num);
    yield return new WaitForSeconds(2f);
    print("Wait Mid: " + startTime + " ~ " + Time.time + ", number: " + num);
    yield return new WaitForSeconds(2f);
    print("Wait End: " + startTime + " ~ " + Time.time + ", number: " + num);
    yield return null;
}

public int num = 0;

void Update ()
{
    if (Input.GetKeyDown(KeyCode.A))
    {
        print("[Start] \"Wait\" by method call and store enumerator, coroutine");
        enumerator = Wait(num++);
        coroutine = StartCoroutine(enumerator);
    }
    if (Input.GetKeyDown(KeyCode.S))
    {
        print("[Start] \"Wait\" by method name and store coroutine");
        coroutine = StartCoroutine("Wait", num++);
    }

    if (Input.GetKeyDown(KeyCode.Z))
    {
        StopCoroutine(enumerator);
        print("[Stop] \"Wait\" by using enumerator");
    }
    if (Input.GetKeyDown(KeyCode.X))
    {
        StopCoroutine("Wait");
        print("[Stop] \"Wait\" by using method name");
    }
    if (Input.GetKeyDown(KeyCode.C))
    {
        StopCoroutine(coroutine);
        print("[Stop] \"Wait\" by using coroutine");
    }
    if (Input.GetKeyDown(KeyCode.V))
    {
        StopAllCoroutines();
        print("[Stop] all \"Wait\" context");
    }
}
{% endhighlight %}

위 예제는 A, S 키를 누르면 _Wait_ 코루틴을 실행시키고, Z,X,C,V 키를 누르면 실행하던 _Wait_ 코루틴을 멈추는 코드로 되어 있다.

조금 더 자세하게 설명하자면, 실행한 방식과 멈추는 방식이 비슷한 제어 방법은 두가지가 있다. 하나는 메소드를 실행시켜 나온 __IEnumerator__ 객체를 통하여 실행하고(A키) 멈추는(Z키) 방법, 나머지 하나는 메소드 이름을 통하여 코루틴을 실행시키고(S키) 멈추는(X키) 방법이 있다.

다만 이름을 통해서 코루틴을 실행하는 방법은 같은 이름의 메소드가 존재할 때는 코드의 위쪽에 있는 것을 실행하고, 이름을 통해 코루틴을 멈추는 방법은 같은 메소드로 호출한 코루틴을 전부 멈추기 때문에 주의하기 바란다.

그리고 코루틴을 멈추는 방법 중 두가지가 더 있는데, 하나는 MonoBehaviour 인스턴스에서 실행한 코루틴을 전부 멈추는 방법, 나머지 하나는 __StartCoroutine__ 이 반환한 객체 __Coroutine__ 을 사용하여 실행한 코루틴 하나를 멈추는 방법이다. __Coroutine__ 객체는 단지 코루틴을 실행했을 때, 실행한 코루틴을 제어하기 위해 사용하는 객체다. 이 __Coroutine__ 객체를 이용해 코루틴을 멈추는게 가장 좋은 듯 하다. __IEnumerator__ 객체를 통하여 멈추는 방식은 중간에 _yield return_ 으로 반환한 객체를 확인 가능하고 직접 제어가 가능하기 때문에 꼭 참조해야할 일이 아니면 __Coroutine__ 객체를 사용하는게 안전할 것이다.

또한 __Coroutine__ 객체는 멈추는 역할 말고도 다른 역할 한가지를 더 수행할 수 있다. 바로 코루틴을 중첩하는 경우에 사용가능한데, 위 예제에 아래 코드를 보자.

{% highlight c# lineos %}
IEnumerator Start()
{
    while (true)
    {
        Coroutine justWait = StartCoroutine("Wait", -1);

        yield return justWait;

        transform.localScale = transform.localScale * 1.1f;
    }
}
{% endhighlight %}

위 코드는 맨 처음 _Wait_ 메소드를 __StartCoroutine__ 을 사용하여 실행한 후, 반환한 __Coroutine__ 객체를 _yield return_ 으로 반환해주면 해당 코루틴이 끝날 때까지 기다려준다. 그리고 기다리는 코루틴이 끝나면 크기를 1.1배 늘려주는 루틴을 계속 반복한다. 위와 같이 __WaitForSeconds__ 나, 실행된 코루틴 객체를 넣어주면 해당 루틴이 끝날 때까지 기다려 주기 때문에, 프레임별로 코딩을 하는 방식에서 시간과 여러 타이밍을 생각하는 비동기적 방식의 코딩이 가능하다. 이는 Unity 의 C# 스크립팅에 혁신적인 변화를 주었다. 그리고 Update 의 사용을 적게 해주기 때문에 Update 콜을 적게해주어 아주 조금의 퍼포먼스 향상도 기대할 수 있다.

하지만 코루틴은 숙달되지 않은 프로그래머가 쓰게되면 그다지 좋은 코딩 방식은 아니다. 코루틴을 처음 접하게 되는 프로그래머는 기존의 프레임별로 실행하던 코드에서 Unity 에서만 쓰이는 코루틴의 개념을 생각하면서 코딩을 해야하기 때문에 상당히 혼란스러울 것이다. 또한 코루틴은 비동기 시스템이기 때문에 Multi Threading 이라 착각하는 경우가 있는데, 단지 Multi tasking 일 뿐이고, 같은 쓰레드에서 실행된다. 아래 그림을 보면 알 수 있을것이다.

![Unity callback order](/images/unity-callback-order.png){: .center-image }

결국 단일 쓰레드에서 실행되는 시스템이면 코루틴을 쓴다고해서 혁신적인 성능향상을 기대하기는 힘들다. 단지 다른 Update 방식이라 생각하면 될듯하다.

## Unity 에서 지원하는 코루틴 대기 제어 기능들

코루틴을 사용할 때 기다려야 할 때 여러 기능들을 제공한다.

대표적인 예는 시간을 기다리는 기능들이다. __WaitForSeconds__ 와 __WaitForSecondsRealtime__ 가 있는데 게임 어플리케이션의 시간과 실제 시간을 기다리는 기능이다. 위에서 __WaitForSeconds__ 를 사용했다.

{% highlight c# lineos %}
IEnumerator Wait(int num)
{
    float startTime = Time.time;
    print("Wait Start: " + startTime + ", number: " + num);
    yield return new WaitForSeconds(2f);
    print("Wait Mid: " + startTime + " ~ " + Time.time + ", number: " + num);
    yield return new WaitForSeconds(2f);
    print("Wait End: " + startTime + " ~ " + Time.time + ", number: " + num);
    yield return null;
}
{% endhighlight %}

위 콜백이 실행되는 그림을 살펴보면 Game Logic 레이어에서 대부분 멈춰준다. 이 타이밍은 _Update_ 가 호출된 후, _LateUpdate_ 가 호출되기 전인데 누군가는 이 시점 말고 다른 시점에 코루틴을 멈추고 싶을 수도 있다. 그래서 Unity 에서는 다른 두 타이밍에 기다림을 멈추는 기능이 있다. __WaitForFixedUpdate__ 과 __WaitForEndOfFrame__ 인데,  __WaitForFixedUpdate__ 는 _FixedUpdate_ 들이 호출된 후 타이밍에 멈춰주는 기능으로써 물리 기반 기능과 같은 타이밍을 공유하고 싶을 때 사용하면 된다. __WaitForEndOfFrame__ 은 한 프레임의 모든 처리가 끝난 후까지 기다려주는 기능으로써 무언가 후처리를 할 때 사용해주면 된다.

또한 사용자가 멈추고 싶은 타이밍에 멈추는 경우도 필요할 것이다. 그래서 두가지 논리적인 조건이 충족할 때 멈춰주는 기능도 있다. __WaitUntil__ 과 __WaitWhile__ 인데, 단순하게 _Func\<bool\>_ 델리게이트만 받아 참이냐, 거짓이냐에 따라서 기다림을 제어한다. __WaitUntil__ 은 델리게이트가 반환하는 값이 _false_ 일 때 다음으로 넘어가고, __WaitWhile__ 델리게이트가 반환하는 값이 _true_ 일 때 다음으로 넘어가기 된다.

마지막으로 프로토콜로 통신하는 기능을 사용할 때 사용하는 __WWW__ 라는 특수한 제어 객체가 있다. 이는 보통 _http_ 통신을 해서 무언가 받아올 때 사용한다. 아래 예제가 대표적인 예시다.

{% highlight c# lineos %}
IEnumerator getGoogle()
{
  WWW google = new WWW("https://www.google.com");
  yield return google;
  print(google.text);
}
{% endhighlight %}

보통은 위 예제처럼 _http_ 통신을 해서 데이터를 가져올 때 사용한다. 로컬 파일 시스템이나 ftp 프로토콜도 가능하다. 자세한 사항은 [Unity WWW](https://docs.unity3d.com/kr/current/ScriptReference/WWW.html) 여기서 확인하라.

이렇게 Unity 에서 기다림을 제어하는 기능에 대해서 알아보았다. 하지만 이 기능들 가지고는 약간 부족한 부분이 있을 것이다. 이를 위해 Unity 에서는 __CustomYieldInstruction__ 이라는 기능을 제공한다.

## CustomYieldInstruction 를 사용해서 커스터마이징하기

__CustomYieldInstruction__ 을 통해 기다리는 기능을 상당히 간단하게 구현이 가능하다. __CustomYieldInstruction__ 는 _keepWaiting_ 이라는 abstract 프로퍼티를 통해 값이 _false_ 일 때는 기다리고, _true_ 일 때는 넘어가는 간단한 __IEnumerator__ 구현체다. 즉 __CustomYieldInstruction__ 을 상속받아 _keepWaiting_ 프로퍼티만 구현하면 끝이다. 아래 transform 의 scale 을 검사해서 일정 값을 초과하게 되면 다음으로 넘어가는 기능을 아래 예제에 첨부했다.

{% highlight c# lineos %}
public class ScaleOverYieldInstruction : CustomYieldInstruction
{
    private Transform transform;
    private Vector3 limit;

    public ScaleOverYieldInstruction(Transform transform, Vector3 limit)
    {
        this.transform = transform;
        this.limit = limit;
    }

    public override bool keepWaiting
    {
        get
        {
            Vector3 scale = transform.localScale;
            return limit.x > scale.x && limit.y > scale.y && limit.z > scale.z;
        }
    }
}
{% endhighlight %}

구현 자체는 상당히 간단하다. 일반적인 클래스 인스턴스 처럼 생성자에서 초기화를 해주고, _keepWaiting_ 구현을 한 것이 보인다. 다만 조금 의문이 드는점은 _keepWaiting_ 은 도대체 언제 호출이 되냐는 것이다.

사실 위의 소개한 기능중에 CustomYieldInstruction 이용해 구현한 기능이 있다. __WaitUntil__ 과 __WaitWhile__ 이다.
[Unity CustomYieldInstruction](https://docs.unity3d.com/ScriptReference/CustomYieldInstruction.html) 을 보면 Update 가 호출된 후, LateUpdate 를 호출하기 전 즉 타이밍이 적혀있는 그림에서 보았을 떄 GameLogic 레이어에서 체크가 된다는 것을 알 수 있다.

## 참조

- [Unity 코루틴 메뉴얼](https://docs.unity3d.com/kr/current/Manual/Coroutines.html)
<!--
- [MSDN : IEnumerator](https://msdn.microsoft.com/ko-kr/library/system.collections.ienumerator.aspx)
- [MSDN : 반복기 사용](https://msdn.microsoft.com/ko-kr/library/65zzykke.aspx)
-->
- [Unity Coroutine ref](https://docs.unity3d.com/ScriptReference/Coroutine.html)
- [Unity CustomYieldInstruction ref](https://docs.unity3d.com/ScriptReference/CustomYieldInstruction.html)
- [Unity YieldInstruction ref](https://docs.unity3d.com/ScriptReference/YieldInstruction.html)
- [Unity In Depth 코루틴 글](http://unityindepth.tistory.com/21)
- [Unity WWW ref](https://docs.unity3d.com/kr/current/ScriptReference/WWW.html)

<!--
ok  유니티의 기본적인 코루틴 사용법? StopCoroutine:Coroutine
ok  장단점?
ok  구현 클래스 예시 WaitUntil, WaitWhile
~~  CustomYieldInstruction : keepwaiting 을 씀, Update 다 된 이후, LateUpdate 하기 전에 체크함
xx  C# 에서의 코드 블록 지원, 코드에서 사용되는 IEnumerator 의 구조
-->
