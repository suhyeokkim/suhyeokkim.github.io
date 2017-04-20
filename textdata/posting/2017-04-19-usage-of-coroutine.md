---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - try
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

코루틴의 동작을 매우 간단하게 표현한 그림이다. 그런데 코루틴은 위 예제에서 호출한 방식 말고도 다른 방식으로 제어가 가능하다. 아래 예제를 살펴보자. [UnityExample](https://github.com/hrmrzizon/UnityExample) 프로젝트의 CoroutineBehaviour 를 참조해도 된다.

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

그리고 코루틴을 멈추는 방법 중 두가지가 더 있는데, 하나는 MonoBehaviour 인스턴스에서 실행한 코루틴을 전부 멈추는 방법, 나머지 하나는 __StartCoroutine__ 이 반환한 객체 __Coroutine__ 을 사용하여 실행한 코루틴 하나를 멈추는 방법이다. __Coroutine__ 객체는 단지 코루틴을 실행했을 때, 실행한 코루틴을 멈추기 위해 사용하는 객체다. 그리고 이 __Coroutine__ 객체를 이용해 코루틴을 멈추는게 가장 좋은 듯 하다. __IEnumerator__ 객체를 통하여 멈추는 방식은 중간에 _yield return_ 으로 반환한 객체를 확인 가능하고 직접 제어가 가능하기 때문에 꼭 참조해야할 일이 아니면 __Coroutine__ 객체를 사용하는게 안전할 것이다.

## 반복을 정의하는 interface : IEnumerator



- CustomYieldInstruction
- IEnumerator

<!--
ok  //  유니티의 기본적인 코루틴 사용법? StopCoroutine:Coroutine
  C# 에서의 코드 블록 지원?
  코드에서 사용되는 IEnumerator 의 구조
  CustomYieldInstruction : keepwaiting 을 씀, Update 다 된 이후, LateUpdate 하기 전에 체크함
  IEnumerator 를 직접 구현한 코루틴 사용
  실 사용 사례? : 틱 사용하기, 시간 체크하기, WWW 체크하기
  장단점?
-->

## 참조

- [Unity 코루틴 메뉴얼](https://docs.unity3d.com/kr/current/Manual/Coroutines.html)
- [Unity Coroutine ref](https://docs.unity3d.com/ScriptReference/Coroutine.html)
- [Unity YieldInstruction ref](https://docs.unity3d.com/ScriptReference/YieldInstruction.html)
- [MSDN : IEnumerator](https://msdn.microsoft.com/ko-kr/library/system.collections.ienumerator.aspx)
- [MSDN : 반복기 사용](https://msdn.microsoft.com/ko-kr/library/65zzykke.aspx)
- [CustomYieldInstruction](https://docs.unity3d.com/ScriptReference/CustomYieldInstruction.html)
