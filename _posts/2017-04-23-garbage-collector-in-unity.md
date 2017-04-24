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

C, C++ 을 제외한 C#, Java, Python 등 주류 애플리케이션 언어들은 대부분 메모리 관리를 garbage collector(이하 GC) 라는 개념을 차용해 메모리를 관리한다. GC 는 특정한 메커니즘을 가지고 어플리케이션에서 사용하는 메모리를 관리해주는 개념이다. GC 는 언어별로, 구현된 사항별로 다르기 때문에 모든 개념이 통용되는 것은 아니지만 대부분 같은 개념에서 출발한다.

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

하지만 reference-couting 은 조금 불편하다. 사용자가 직접 카운트를 관리해야하는 것은 결국 메모리 관리 전략을 직접 짜는것이기 때문이다. 그 후 1990년 대 후반에 등장한 언어들은 전부 garbage-collector 개념을 차용했는데 대표적인 언어가 위에서도 언급한 JAVA 와 C# 이다. 현재 두 언어 모두 Generational GC 방식을 사용한다. 세대별로 사용하는 메모리를 나누어 관리하는 방식인데, 우리는 이 방식을 알아보기 전에 garbage-collector 의 기본적인 개념부터 살펴볼 것이다.

## Mark and Sweep

mark and sweep 은 garbage-collector 방식 중에 시초가 되는 방식이며, 가장 간단한 개념이다. 이름만 살펴보면 표시하고(mark) 쓸어담기(sweep) 로 알 수 있는데 조금 더 풀어보면, 사용하는 메모리를 표시하고(mark) 메모리가 부족하거나 안쓰는 메모리를 없에야 할 때 표시가 해제된 메모리 영역을 쓸어담아(sweep) 청소하는 방식이라 할 수 있다. 그림으로 표현하자면

![mark and sweep 0](/images/mark_and_sweep_0.png){: .center-image }

어플리케이션 메모리에서 새롭게 오브젝트가 생성 되었을 때의 상태를 표시했다. 상자들에 붙어 있는 초록색 번개는 사용중인 오브젝트를 표시(mark)한 것이다.

![mark and sweep 1](/images/mark_and_sweep_1.png){: .center-image }

꽤 시간이 지난 후 Object2 가 더 이상 필요하지 않아 Object2 를 사용되지 않는다고 표시(mark) 하였다.

![mark and sweep 2](/images/mark_and_sweep_2.png){: .center-image }

garbage-collector 가 메모리들을 정리할 때가 되어 사용되지 않는 메모리들을 전부 쓸어서(sweep) 정리한다. 이것이 mark and sweep 의 개념이다.

## Generational GC : 세대 단위 가비지 컬렉터

<!--
   가비지 컬렉션 개요?

   혼자서 관리하기
   REF-Count 방식
   mark-sweep(-compact) 방식
   Generational 방식

   Mono-Runtime 설명

   Mono Boehm 가비지 컬렉션 작동 원리
   Mono SGen 가비지 컬렉션 작동 원리

   실질적인 가비지 컬렉션 원인
    - ToString(), ToArray() 등의 컨테이너 컨버팅 메소드 : 대안(참조 방식 가져오는게 있음)
    - string + operator : 대안(string.Format, StringBulider)
    - 언박싱,박싱(유니티 코루틴에서 언박싱 발생) : 대안(Generic 사용)

  IDisposable, using keyword
-->

## 참조

- [위키피디아(한글) 쓰레기 수집기](https://ko.wikipedia.org/wiki/%EC%93%B0%EB%A0%88%EA%B8%B0_%EC%88%98%EC%A7%91_%28%EC%BB%B4%ED%93%A8%ED%84%B0_%EA%B3%BC%ED%95%99%29)
- [참조 횟수 계산 방식](https://ko.wikipedia.org/wiki/%EC%B0%B8%EC%A1%B0_%ED%9A%9F%EC%88%98_%EA%B3%84%EC%82%B0_%EB%B0%A9%EC%8B%9D)
- [MSDN : 가비지 수집기 기본 및 성능 힌트](https://msdn.microsoft.com/ko-kr/library/ms973837.aspx)
- [C# GC](http://ronniej.sfuh.tk/c-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EA%B4%80%EB%A6%AC-%EC%A3%BC%EA%B8%B0-%EC%8A%A4%EC%BD%94%ED%94%84-%EA%B0%80%EB%B9%84%EC%A7%80-%EC%BB%AC%EB%A0%89%EC%85%98-lifetime-scope-garbage-collection/)
- [NAVER D2 : JAVA garbage collector](http://d2.naver.com/helloworld/1329)
- [Boehm garbage collector](https://en.wikipedia.org/wiki/Boehm_garbage_collector)
- [Boehm-Demers-Weiser GC in C/C++](https://github.com/ivmai/bdwgc)
- [Mono GC](http://www.mono-project.com/docs/advanced/garbage-collector/sgen/)
- [Mono working with SGen](http://www.mono-project.com/docs/advanced/garbage-collector/sgen/working-with-sgen/)
- [Wikipedia : Reification](https://en.wikipedia.org/wiki/Reification_(computer_science))
- [Wikipedia : C#](https://en.wikipedia.org/wiki/C_Sharp_(programming_language))

## 참조 문서 다운로드 링크

- [Boehm Tutorial - PPT 다운로드 링크](http://www.research.ibm.com/ismm04/slides/boehm-tutorial.ppt)
- [Bounding Space Usage of Conservative Garbage Collectors](https://pdfs.semanticscholar.org/b5de/c18f67406975f98a2e20dfb362d4e0542a91.pdf)
