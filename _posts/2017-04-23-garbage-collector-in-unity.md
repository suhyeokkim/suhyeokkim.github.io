---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
    - mono
    - c#
    - gc
    - analysis
---

C, C++ 을 제외한 C#, Java, Python 등 주류 애플리케이션 언어들은 대부분 메모리 관리를 garbage-collector(이하 GC) 라는 개념을 차용해 메모리를 관리한다. GC 는 특정한 메커니즘을 가지고 어플리케이션에서 사용하는 메모리를 관리해주는 개념이다. GC 는 언어별로, 구현된 사항별로 다르기 때문에 모든 개념이 통용되는 것은 아니지만 대부분 같은 개념에서 출발한다.

<!-- more -->

C 언어와 C++ 언어에서는 기본적으로 메모리 관리를 사용자가 __직접__ 하도록 한다. 요즘 많이 쓰이는 스크립트 언어들과는 달리 높은 퍼포먼스 대비 약간의 불편함을 감수하는 언어로 설계되었기 때문이다. 아래 예제처럼 말이다.

{% highlight c lineos %}
void* pt = malloc(10);

// 사용 코드..

free(pt);
{% endhighlight %}

위처럼 시스템에 메모리를 요청해 직접 가져오고, 사용을 끝낸 메모리 공간들을 반환하는 시스템은 소프트웨어의 빠른 개발과 안정성을 방해한다. 메모리를 직접 관리해야 하기 때문에 메모리 관리 코드를 일일히 만들어 주어야 한다. 게다가 잘못 사용하게 되면 프로그램의 크래쉬를 유발하기까지 한다.

이러한 특징 때문에 많은 언어에서는 자동으로 메모리를 관리하는 여러가지 시스템이 있었는데, 직접 관리해주는 방식에서 간단하게 변형된 메모리 관리 방식이 있다. 바로 reference-couting 방식이다.

필자가 사용해본 언어에서 reference-couting 을 쓴 언어는 iOS 를 개발할 때 objective-c 를 사용해서 개발했었는데, 언어 자체에서 최상위 객체를 reference-couting 방식을 사용해 구현해 놓아서 당연히 reference-couting 방식을 사용해 개발을 해야했었다. 아래 objective-c 예제가 있다.

{% highlight Objective-C lineos %}
NSString* s = [[NSString alloc] init];  // NSString 오브젝트 생성 레퍼런스 카운트 1 올라감

// 객체 사용 코드..

[s release];                            // 레퍼런스 카운트 1 내려감
{% endhighlight %}

reference-couting 이란 객체를 참조하는 횟수를 세서 참조 횟수가 0이 되면 할당을 해제하는 방식이다. 위의 예제에서는 첫줄에 오브젝트를 생성할 때 ref-count 를 1 올려주고, 사용이 끝난 후에는 __release__ 메소드를 사용해 ref-count 를 1 낮추어 메모리를 해제하는 것을 보여준다.

하지만 reference-couting 은 조금 불편하다. 사용자가 직접 카운트를 관리해야하는 것은 결국 메모리 관리 전략을 직접 짜는것이기 때문이다. 그 후 1990년 대 후반에 등장한 언어들은 전부 ㅎ 개념을 차용했는데 대표적인 언어가 위에서도 언급한 JAVA 와 C# 이다. 그 이후에도 많은 고수준 언어들이 GC 개념을 차용했다. 그 중 우리는 Unity 에서 쓰이는 GC 의 개념에 대해서 알아볼 것이다.

## Mono-runtime 에서의 GC

Unity 는 여러 언어를 지원하기 위해 Mono 라는 오픈소스 언어 변환 프레임워크를 사용한다. 현재 Unity 에서 사용 가능한 언어들은 C#, JavaScript, Boo 가 있는데 전부 Mono 지원 언어의 하위 집합들이다. 즉 Unity 가 돌아가는 것은 Mono 기반의 가상머신에서 돌아가는 것이다. 이렇게 실제 runtime 상에서 돌아가는 가상머신을 [Mono-runtime](http://www.mono-project.com/docs/advanced/runtime/) 이라 칭하는데 Mono 는 C# 을 주로 타게팅하고 만들어진 프레임워크이기 때문에 [Mono-runtime](http://www.mono-project.com/docs/advanced/runtime/) 은 GC 를 탑재해야 했다.

Mono 2.8 이하 버젼에서는 _Boehm-Demers-Weiser_(이하 _Boehm_) 라는 이름의 GC 알고리즘을 택했었는데, 이는 1988년에 처음 릴리즈되었고 ([license](http://www.hboehm.info/gc/license.txt)) C/C++ 를 타겟으로 만들어진 GC 라이브러리로써([Github](https://github.com/ivmai/bdwgc)) 당시 쓸만한 GC 였던 것 같다. [_SGen_ Introduction](https://schani.wordpress.com/2010/12/20/sgen/) 에서는 안정성과 이식성이 좋아 쓰였다고 한다. 하지만 _Boehm_ GC 는 C/C++ 을 타겟으로 구현되었다. 그래서 여러 문제와 한계가 있어 Mono-runtime 은 다른 대안이 필요했다. 결국 Mono 에서는 직접 GC 를 개발했다. 주로 칭하는 이름은 _SGen_ 길게 풀면 _Simple Generational_ 이다. Mono 2.8 버젼부터는 _SGen_ 으로 GC 를 통채로 바꾸었다.

하지만 지금 Unity 에서 쓰는 Mono 의 버젼은 2.8 을 넘지 못한다. 또한 직접 파일을 확인해 Mono 의 정보를 보면 아래와 같이 command line 에서 확인할 수 있다.

![mono --version](/images/mono_version.png){: .center-image }

보다시피 GC 항목에는 _Include Boehm_ 이라고 쓰여 있다. 이 구버젼의 Mono 는 언제부터 유지되었는지 정확한 날짜는 모르겠다. 하지만 Unity 3.X 버젼부터 계속 유지되어온 것같다. 안정성 문제를 따져보면 Mono 2.8 이 릴리즈 된지는 7년이 지나고 있다. 개선이 된지 한참이 지났을텐데 왜 패치를 안하는지는 모르겠다. 이는 일부 사용자들에게 꽤나 많은 원성을 그전부터 계~속 받고 있었다.([SCRIPTING: GARBAGE COLLECTION SGEN-GC](https://feedback.unity3d.com/suggestions/scripting-garbage-collection-sg) : 2010년에 올라온 글이다.)

그나마 다행인 것은 최근 Unity 에서는 Mono 버젼업을 하겠다는 의지를 보였다. Unity 5.5 버젼에서는 Mono 컴파일러 버젼업을 했으며, 당장은 아니지만 이전에 Mono 업데이트를 하겠다는 글이 올라왔었다.([joins-the-net-foundation](http://blogs.unity3d.com/2016/04/01/unity-joins-the-net-foundation/)) 하지만 가장 최근에 릴리즈된 5.6 버젼에서는 Mono-runtime 자체는 그대로 구버젼을 쓰고 있다. 일단은 기다려 보자.

현재 Unity 에서 쓰이는 Mono-runtime 에 대해서 알아보았다. 아래에서는 언제가 될지 모르는 Mono 프레임워크 업데이트에 대비해 _SGen_ 의 간단한 동작방식과 쓰이는 여러 알고리즘에 대해서 알아볼것이다.

## SGen 에서 쓰이는 GC 알고리즘

SGen 에서는 전통적으로 많이 쓰이는 여러 알고리즘을 사용한다. 대부분 대중적으로 많이 알려진 알고리즘을 채용해 알아두면 꽤 많은 도움이 될것이다.

### _mark-and-sweep_ GC

_mark-and-sweep_ 은 GC 알고리즘 중에서도 시초가 되는 알고리즘이며, 가장 간단한 GC 방법이다. 이름만 살펴보면 표시하고(_mark_) 쓸어담기(_sweep_) 로 알 수 있는데 조금 더 풀어보면, 메모리가 부족하거나 안쓰는 메모리를 없에야 할 때 사용하는 메모리를 표시하고(_mark_) 표시가 해제된 메모리 영역을 쓸어담아(_sweep_) 청소하는 방식이라 할 수 있다. 그림으로 표현하자면

![mark and sweep 0](/images/mark_and_sweep_0.png){: .center-image }

어플리케이션 메모리에서 새롭게 오브젝트가 생성 되었을 때의 상태를 표시했다. 상자들에 붙어 있는 초록색 번개는 사용중인 오브젝트를 표시(_mark_)한 것이다. 보통은 오브젝트 한개당 1bit 를 사용한다.

![mark and sweep 1](/images/mark_and_sweep_1.png){: .center-image }

꽤 시간이 GC 가 쓸기(_sweep_) 행동을 하여 사용되지 않는 오브젝트를 청소하려 했으나 아무것도 없어 그냥 넘어가고, Object2 가 더 이상 참조되지 않아 Object2 를 사용되지 않는다고 표시(_mark_) 하였다.

![mark and sweep 2](/images/mark_and_sweep_2.png){: .center-image }

GC 가 메모리들을 정리할 때가 되어 사용되지 않는 메모리들을(_unreachable_) 전부 쓸어서(_sweep_) 정리한다. 이것이 _mark-and-sweep_ 의 개념이다. _Boehm_ GC 은 이 _mark-and-sweep_ 을 기본 개념으로 채용하는 알고리즘이다.

기본적인 _mark-and-sweep_ 은 두가지 문제를 가지고 있다. _sweep_ 단계에서 모든 개체들을 추적하여 체크해야 하는것이 있고, 메모리 단편화에([Wiki : Memory Fragmentation](https://en.wikipedia.org/wiki/Fragmentation_%28computing%29)) 대한 대책이 없다. 첫번째 문제는 _Generation GC_ 에서 확인하고, 두번째 메모리 단편화에 대한 문제에 대해 알아보자. 아래 그림을 보면된다.

| ![fragmentation](/images/fragmentation.png) |
| :-----: |
| [출처 : brewmp developer site](https://developer.brewmp.com/resources/tech-guides/memory-and-heap-technology-guide/high-level-architecture/memory-fragmentation) |
| |

위 그림은 1,2,3,4 숫자 순서대로 실행되는 그림인데, 저 순서대로 진행되어 중간중간에 16kb 가 비게 되어 메모리가 조각난다면(fragmentation), 16kb 보다 더 큰 메모리를 한꺼번에 할당할 때 문제가 생긴다. 그래서 상용에서 쓰이는 GC 가 _mark-and-sweep_ 을 사용했을 때에 대비한 많은 해결책이 있는데,  단점을 보완한 개량된 여러 버젼의 알고리즘이 꽤 많이 존재한다. _mark-and-sweep_ 자체를 개량한 [_mark-and-compact_](https://en.wikipedia.org/wiki/Mark-compact_algorithm) 알고리즘이 _mark-and-sweep_ 과 가까운 알고리즘이다. 하지만 _SGen_ 은 다른 알고리즘을 사용했다.

### _Copying_ GC

한글로는 객체 이동 기법이라 하고, 영어로는 "_Copying_" 이라고 한다. _mark-and-sweep_ 에서 중간 중간 비는 메모리 파편화(fragmentation)를 메커니즘을 바꾸어 해결한 케이스인데 자세한 사항은 아래 그림을 보자.

| ![copying](/images/copying_garbage_collection.svg){: .center-image } |
| :-----: |
| [출처 : memorymanagement.org](http://www.memorymanagement.org/) |
| |

위 그림에서는 3단계를 나누어 _Copying_ GC 를 설명하고 있는데, 쓰레기 수집(collection) 전에 이미 흰색으로 마크된 닿을 수 없는(unreachable), 버려진 메모리와 현재 사용중인 메모리가 한 공간에 존재한다. 또한 첫번째 그림에는 없지만 현재 실제로 사용하는 메모리가 있는 공간 외에도 같은 크기의 크기를 가진 공간이 하나 더 존재한다. 두번째 그림을 보면 이해가 갈것이다. 쓰레기 수집(collection) 을 하게 되면, 사용하던 메모리들이 존재하던 공간말고 다른 공간에 사용하던 메모리들만 복사한다. 이때 버려진(unreachable, dead) 메모리들은 복사하지 않는다. 복사 과정이 끝나면 기존에 있던 메모리 정보들은 싹다 지운다. 다음 쓰레기 수집(collection) 과정에서 싹다 지워버린 공간(남겨진 공간)으로 복사 후 쓰던 공간을 지우는 것을 반복한다. 이렇게 복사(copying)하고, 지우고 하는 과정이 무한 반복되는 방법이 _Copying_ GC 알고리즘이다.

### _Generational_ GC

위에서 GC 알고리즘 2가지에 대해서 알아 보았는데, 두 방법들이 메모리를 직접 관리하는 방법에 대한 것이라면, _Generational_ GC 의 접근 방법은 조금 다르다. 일반적인 메모리의 생명 주기는 아주 짧게 있다가 사라지거나, 아주 오랜 기간 동안 쓰인다. 그래서 힙을 두개 이상의 세대(_Generational_)로 나누어 다른 방식으로 관리하는 "_generational hypothesis_"(세대 별 가설) 을 사용하는 것이 _Generational_ GC 의 기본적인 접근 방식이다.

세대 별 가설은 구현된 플랫폼, 언어 별로 다 다르다. 하지만 여러 사례들을 보고 전체적으로 살펴보면 크게 다를 바는 없다.(물론 세부 구현은 다르겠지만) 이 글에서는 _SGen_ 만 살펴보도록 하겠다. _SGen_ 의 전체 이름은 _Simple Generational_ GC 다. 세대 구성이 간단하다는 뜻을 가지고 있는데, 이름과 같이 아주 여러개의 세대를 가지고 있는게 아니라 딱 2개의 세대로만 분리한다. 하나는 _Nursery_ 이고, 나머지 하나는 _Major Heap_ 이다. 우선 _Nursery_ 부터 알아보자.

_Nursery_ 는 아기방, 보육원 이런 늬앙스를 가지고 있는데 뜻과 같이 처음 생겨나는 메모리 개체가 생성되는 세대다. _Nursery_ 의 전략은 빠르게 사라지는 메모리들을 수집하고, 유지되는 메모리 개체들을 상위 세대에 빠르게 올리는 목적이라 쓰레기 수집(GC)의 빈도가 높다. 메모리 개체가 일정 기간 동안 혹은 일정 GC 횟수가 지나고 살아 남아 있다면 상위 세대로 승진(_promote_) 시킨다. 바로 _Major Heap_ 으로 말이다. 참고로 두 세대의 용도가 다르므로 _Nursery_ 와 _Major Heap_ 은 수집 알고리즘이 조금 다르다.

아래에 간단하게 _SGen_ 의 동작 방식을 그림으로 살펴보자.([Working with SGen](http://www.mono-project.com/docs/advanced/garbage-collector/sgen/working-with-sgen/))

![SGen hypothesis 1](http://www.mono-project.com/archived/images/1/15/SGenSpaces.png)

가장 처음 응용 프로그램이 실행 되었을 때다. 가장 처음에는 사용하는 메모리 공간이 없으므로 모든 공간들이 비어 있다.

![SGen hypothesis 2](http://www.mono-project.com/archived/images/4/43/SgenNurseryAlloc.png)

실행한지 시간이 조금 지나게 되어 _Nursery_ 에 새로운 개체들이 점점 늘어난다.

![SGen hypothesis 3](http://www.mono-project.com/archived/images/5/58/SgenEvacuation.png)

어떤 규칙이나, 혹은 _Nursery_ 의 공간이 거의 가득 찼을 때, 쓰레기 수집을 하고 몇번의 쓰레기 수집에서 살아남은 메모리 개체들을 _Nursery_ 에서 _Major Heap_ 으로 승진시킨다. 옆의 _Large Object Space_ 는 지정된 크기(기본값은 8000바이트)를 초과하는 큰 메모리 개체들을 관리하는 공간이다.

_SGen_ 에서 쓰이는 GC 알고리즘들에 대해 간단히 알아보았다. 자세히 알아보지 않는 이유는 어차피 몰라도 코드를 짤때도 몇가지 사항들만 조심한다면 크게 문제될 것은 없다. 하지만 프로그래머로써의 최소한의 상식들을 위해 알아보았다. 한가지 상식을 위해 덧붙이자면 _Boehm_ 은 _mark-and-sweep_ 을 기본 개념으로 차용한다. 아래 항목들에서는 실제 스크립팅에서 억울하게 버려지는 메모리를 발생시키는 코드들에 대해서 알아볼 것이다.

## Unity 스크립팅에서 실질적인 가비지 컬렉션 원인 및 대안

위에서 우리는 실제로 코딩과는 그다지 상관없는 정보를 얻었다. 결국 프로그래머에게 가장 중요한것은 본인의 코딩이 어떤 영향을 끼치는 것인지가 중요하다. Unity 스크립팅에서 쓰레기를 남겨 청소를 하게 만드는(Garbage Collecting 을 유발하는) 몇가지 방법에 대해 알아보자.

### ToString(), ToArray() 등의 데이터 컨버팅 메소드

C# 에서 지원하는 대부분의 자료형들은 _ToString_ 이라는 메소드를 지원한다. 이는 데이터를 문자열로 변환하는 메소드 인데, 정확히 말하자면 문자열을 새로 만들어(allocation) 그 문자열에다가 데이터의 타입, 값 자체를 쓴다. 우리가 주목할 부분은 문자열을 새로 만드는게 중요한 것이다. 대부분 코드에서는 _ToString_ 을 남발하기 십상인데, 매 프레임마다 호출되는 _Update_ 메소드에서 _ToString_ 을 남발했다가는 꽤나 심한 프레임 드랍이 일어날 것이다.

{% highlight c# lineos %}

void Update()
{
  print(1.ToString());
}

{% endhighlight %}

이렇게 To 접두사가 붙는 데이터 컨버팅 메소드는 메모리 공간을 새로 할당하는 메소드가 대부분이다. 최대한 사용을 자제해야 하고, __List__ 컨테이너의 _ToArray_ 메소드 같은 컨테이너 컨터팅 메소드는 대부분 __ref__ 문법을 사용해 존재하는 배열에 값을 써주는 메소드가 존재한다.

### string + 연산자 사용

C# 은 문자열 자체도 객체로 보기 때문에 여러 기능을 사용할 수 있는데 그 중 편리하게 사용되는 기능은 '+' 연산자 오버로딩이다. 이 기능은 문자열과 문자열을 합쳐주는 기능으로 사용시 조금 부담이 있다.

{% highlight c# lineos %}

print("check : " + (5+5) + "..");

{% endhighlight %}

위의 예제에서 '+' 연산자 오버로딩을 통해 문자열 3개를 합치는 모습이 나오는데, 총 두번 합치는 것을 실행한다. 맨 처음 _"check : "_ 문자열과 (5+5) 를 문자열로 컨버팅한 _"10"_ 문자열을 합친다. 그러면 _"check : 10"_ 문자열이 새로 생기는데 문제는 다음이다. 새로 생긴 _"check : 10"_ 과 _".."_ 를 합친다. 그러면 _"check : 10.."_ 문자열이 새로 생기고, print 메소드가 실행된 이후에는 새로 생긴 한개의 문자열 _"check : 10"_ 이 정말 쓸데없이 버려지게 된다.

이렇게 '+' 연산자 때문에 버려지는 메모리를 안생기게 하려면 다른 방법이 있다. 하나는 __.Net__ 의 _string.Format_ 메소드다. C 를 배워본 사람이라면 알겠지만 문자를 출력할 때 서식을 이용해 서식 문자열과 함께 인자를 넣어 각 함수가 알아서 서식 문자에 넣어둔 데이터를 읽어 새로운 문자열을 만들어 주는 것이다. 하나는 __.Net__ 의 __StringBulider__ 클래스다. 빌더 패턴을 이용해 문자열을 합치는 기능을 제공하는 클래스로 조금 더 직관적이고 _string.Format_ 처럼 한번에 바꾸는게 아니라 _ToString_ 함수를 통해 새로운 인스턴스를 원하는 시점에 만들 수 있어 동적인 환경에서 편하게 사용할 수 있다.

{% highlight c# lineos %}

int data = 5+5;
StringBuilder builder = new StringBuilder();

print(string.Format("check : {0}..", data));
print(builder.Append("check : ").Append(data).Append("..").ToString());

{% endhighlight %}

### 박싱 : 스택 데이터를 __object__ 로 변환시킬 때

이 설명은 [MSDN](https://msdn.microsoft.com/ko-kr/library/yz2be5wk.aspx) 에서 가져왔다.

여기서 우리가 주의깊게 살펴볼 사항은 버려지는 메모리인데, 여기서 버려지는 메모리는 스택에 존재하는 단순 값들을 __object__ 로 반환할 때 생기는 일이다. 이런일은 잘 발생하지 않지만 짚고 넘어가보겠다.

{% highlight c# lineos %}
int i = 123;
object o = (object)i;  // explicit boxing
{% endhighlight %}

![MSDN : boxing](https://i-msdn.sec.s-msft.com/dynimg/IC165510.jpeg){: .center-image }

위 코드처럼 객체가 아닌 stack 에 존재하는 데이터를 박싱할 때 사본은 heap 에 생성하므로써, 잠시 이용하고 버려지는 메모리가 발생하게 된다. 또한 이런 코드는 성능에도 영 좋지 않으니 남발하지 않는게 좋다.

## 참조

- [위키피디아(한글) 쓰레기 수집기](https://ko.wikipedia.org/wiki/%EC%93%B0%EB%A0%88%EA%B8%B0_%EC%88%98%EC%A7%91_%28%EC%BB%B4%ED%93%A8%ED%84%B0_%EA%B3%BC%ED%95%99%29)
- [참조 횟수 계산 방식](https://ko.wikipedia.org/wiki/%EC%B0%B8%EC%A1%B0_%ED%9A%9F%EC%88%98_%EA%B3%84%EC%82%B0_%EB%B0%A9%EC%8B%9D)
- [MSDN : 가비지 수집기 기본 및 성능 힌트](https://msdn.microsoft.com/ko-kr/library/ms973837.aspx)
- [C# GC](http://ronniej.sfuh.tk/c-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EA%B4%80%EB%A6%AC-%EC%A3%BC%EA%B8%B0-%EC%8A%A4%EC%BD%94%ED%94%84-%EA%B0%80%EB%B9%84%EC%A7%80-%EC%BB%AC%EB%A0%89%EC%85%98-lifetime-scope-garbage-collection/)
- [Boehm garbage collector](https://en.wikipedia.org/wiki/Boehm_garbage_collector)
- [Github : Boehm-Demers-Weiser GC](https://github.com/ivmai/bdwgc)
- [Mono-runtime](http://www.mono-project.com/docs/advanced/runtime/)
- [Mono GC](http://www.mono-project.com/docs/advanced/garbage-collector/sgen/)
- [Mono working with SGen](http://www.mono-project.com/docs/advanced/garbage-collector/sgen/working-with-sgen/)
- [SGen](https://schani.wordpress.com/2010/12/20/sgen/)
- [Unity feedback : SCRIPTING: GARBAGE COLLECTION SGEN-GC](https://feedback.unity3d.com/suggestions/scripting-garbage-collection-sg)
- [Benchmark Boehm vs SGen using GraphDB ](http://www.schrankmonster.de/2010/09/01/taking-the-new-and-shiny-mono-simple-generational-garbage-collector-mono-sgen-for-a-walk/)
- [Copying garbage collection](http://www.cs.cornell.edu/courses/cs312/2003fa/lectures/sec24.htm)
- [NAVER D2 : JAVA garbage collector](http://d2.naver.com/helloworld/1329)
- [Wikipedia : C#](https://en.wikipedia.org/wiki/C_Sharp_%28programming_language%29)
- [MSDN : boxing and unboxing](https://msdn.microsoft.com/ko-kr/library/yz2be5wk.aspx)

## 참조 문서 다운로드 링크

- [Boehm Tutorial - PPT 다운로드 링크](http://www.research.ibm.com/ismm04/slides/boehm-tutorial.ppt)
- [Bounding Space Usage of Conservative Garbage Collectors](https://pdfs.semanticscholar.org/b5de/c18f67406975f98a2e20dfb362d4e0542a91.pdf)
