---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - c#
---

C# 언어에는 IEnumerator 를 사용한 몇몇의 기능들이 존재한다. List 같은 컨테이너부터 코드로 반복기를 만들어 제어하는 기능 등 여러가지를 제공하는데 그것들에 대하여 한번 알아보자.

<!-- more -->

## __IEnumerator__ 가 무엇인가요?

__IEnumerator__ 는 단순한 반복의 개념을 인터페이스로 정의해놓은 것이다. 아래 코드에 정의를 가져왔다.

{% highlight c# lineos %}
public interface IEnumerator
{
    object Current { get; }

    bool MoveNext();
    void Reset();
}
{% endhighlight %}

단순한 인터페이스다. 총 세가지 종류의 필드와 메소드가 있는데, _Current_ 는 반복을 하는 중 현재 가리키는 항목을 가리키는 필드다. _MoveNext_ 는 다음 항목으로 이동하는 메소드인데, 다음 항목으로 더 이상 이동할 수 없으면 false 를 반환한다. _Reset_ 은 계속 반복하던 것을 초기값으로 설정하는 메소드이다. 이렇게 설명만 나열해 놓으면 이해하기 어려우니 가장 접하기 쉬운 예제를 하나 보자. 아마 본적이 있을 수도 있다.

{% highlight c# lineos %}
List<int> integerList = new List<int>();
integerList.Add(1);
integerList.Add(3);
integerList.Add(2);
integerList.Add(4);

IEnumerator<int> enumerator = integerList.GetEnumerator();
while(enumerator.MoveNext())
    Console.WriteLine(enumerator.Current + "\\n");
{% endhighlight %}

위 예제는 _int_ 값을 연속적으로 가지고 있는 _integerList_ 에서 __IEnumerator<int>__ 를 생성해 _integerList_ 의 값을 순서대로 화면에 찍는 코드다. 우리가 주목할 부분은 새롭게 __IEnumerator<int>__ 를 생성하는 코드부터다. 생성 후 enumerator 의 _MoveNext_ 다음 항목으로 가는 메소드를 호출한다. 이때 다음으로 이동하지 못하면 루프를 탈출한다. 그 다음 _Console.WriteLine_ 함수에 _enumerator.Current_ 의 값을 넣어주어 화면에 출력한다.

이렇게 __IEnumerator__ 는 세가지 필드와 메소드로 컨테이너의 반복을 보여주었다. C# 에서 지원하는 대부분의 컨테이너는 __IEnumerator__ 의 서브클래스를 지원하여 반복해서 데이터들을 참조할 수 있게 해준다.

하지만 여기서 __IEnumerator__ 의 활용이 끝나는 것은 아니다. C# 은 단순한 데이터의 반복을 코드로도 지원하기 위해 반복기라는 개념을 구현해 놓았다.

## 반복기는 또 뭔가요?

위에서는 구현되어 있는 컨테이너에서 __IEnumerator__ 객체를 가져와서 사용했다면, 이번에는 코드로 반복하는 개념을 만들어 볼 수도 있다. 아래 코드를 보자.

{% highlight c# lineos %}
public System.Collections.IEnumerator GetEnumerator()
{
    for (int i = 0; i < 10; i++)
    {
        yield return i;
    }
}

public void PrintNumbers()
{
    IEnumerator enumerator = GetEnumerator();
    while(enumerator.MoveNext())
        Console.WriteLine(enumerator.Current + "\\n");
}
{% endhighlight %}

이 코드를 돌려보면 아마 0 부터 9까지 출력되는 모습을 볼 수 있을 것이다. 처음 보는 키워드에 당황할 수도 있지만 당황하지 말고 천천히 살펴보자. 일단 출력하는 코드는 위쪽에 있는 예제와 같다. 우선 반복은 똑같이 한다는 것을 알 수 있다. 하지만 처음 보는 키워드는 당최 이해하기 조금 힘들다. _return_ 키워드는 반환값을 메소드 밖으로 반환하고 메소드를 종료하는 것에 보통 쓰이는데 저기 쓰여 있는 _yield return i_ 는 메소드를 종료하는 것처럼 보이지는 않는다. 결과값는 0 부터 9 까지 출력되고 _yield return i_ 는 0 부터 9 까지의 값을 반환하니 말이다.

![Iterator Run Diagram](/images/csharp_iterator_run.png){: .center-image }

위 그림에 반복기가 _MoveNext_ 를 호출했을 때 하는 행동에 대해서 나와있다. _MoveNext_ 메소드를 호출하면 _yield return_ 구문이 나오거나 코드가 끝날 때까지 실행한다. _yield return_ 구문이 나와서 뭔가 반환하면 그 값을 __IEnumerator__._Current_ 에 넣는다. 그리고 true 를 반환하고 끝낸다. _yield return_ 구문이 안나오고, 코드가 끝이나면 false 를 반환하고 끝난다. 결국 반복기의 제어는 _MoveNext_ 에 달려있는 셈이다. 그리고 __IEnumerator__._Reset_ 은 반복기에서는 지원이 안된다.

## 참조

- [MSDN : IEnumerator 인터페이스](https://msdn.microsoft.com/ko-kr/library/system.collections.ienumerator.aspx)
- [MSDN : 반복기 사용](https://msdn.microsoft.com/ko-kr/library/65zzykke.aspx)
