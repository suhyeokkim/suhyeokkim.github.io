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

C, C++ 을 제외한 C#, Java, Python 등 주류 애플리케이션 언어들은 대부분 메모리 관리를 garbage collector(이하 GC) 라는 개념을 차용해 메모리를 관리한다. GC 는 특정한 메커니즘을 가지고 어플리케이션에서 사용하는 메모리를 관리한다. 언어별로, 구현된 사항별로 다르기 때문에 모든 개념이 통용되는 것은 아니지만 대부분 같은 개념에서 출발한다. 우선 많이 쓰이는 개념부터 살펴보자.

<!-- more -->



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

## 참조 문서 다운로드 링크

- [Boehm Tutorial - PPT 다운로드 링크](http://www.research.ibm.com/ismm04/slides/boehm-tutorial.ppt)
- [Bounding Space Usage of Conservative Garbage Collectors](https://pdfs.semanticscholar.org/b5de/c18f67406975f98a2e20dfb362d4e0542a91.pdf)
