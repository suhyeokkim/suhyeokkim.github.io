---
layout: post
author: "Su-hyeok Kim"
comments: true
categories:
  - jekyll
  - makeblog
  - try
---

블로그를 만들고 나니 설정해주어야 할 것들이 많았다. 많이 헤멘 부분도 있어 경험들을 적어둔다.

# 각종 서비스 붙이기

정적 블로그에 붙일 수 있는 기능들은 엄청 많다. 붙인 기능들에 대하여 기록한다.

## Disqus : 댓글 플랫폼

정적 블로그들은 거의 Disqus 를 사용하는 추세이고, 여러 사이트에서도 사용한다. 느낀점은 이식성이 뛰어나서 붙이기 편했고, 이메일 인증방식도 가지고 있어 어느정도 보안이 되는 느낌이였다.

이식하는 방법은 Disqus 계정을 만들고, 세팅을 한 후 약간의 코드만 붙여주면 된다. 절차는 아래와 같다.

> 1. [Disqus 홈페이지][disqus_home] 에 가입한다.
> 2. 자신의 사이트 세팅을 만든다.
> 3. 사이트 관리 창으로 이동한다.
> 4. Installing disqus 를 선택 후 jekyll 을 선택한다.
> 5. Universal Embeded Code 를 \_includes 폴더에 파일로 하나 만들어 둔다. (코드 조각을 저장해둔다고 생각하면된다.)
>   - __주의할점__ : \{% if page.comments %\} 안에 이 코드를 넣으라고 써있다. 이 코드는 포스팅 글에서 comments: true 가 되어 있는지 검사하는 구문이다. 그러니 코드 조각안에 if/endif 구문을 넣어주는게 좋다.
> 6. 그리고 원하는 layout 에 \{% include (파일이름) %\} 이 코드를 원하는 곳에 넣어주면 작동한다.
> 7. 각각의 포스팅 글위에 위치하는 header 정보에 "comments: true" 가 있으면 댓글이 나온다.

## Travis-ci : Continuous Intergration

다른 Github 블로그, Repository 를 살펴보면서 많은 곳에서 사용하고 있어 한번 시도해 보았다. 블로그를 만들기 이전부터 CI 에 대한 소식은 많이 들었지만 직접 사용해보는 것은 처음이였다.
Travis 전용 웹 문서들이 꽤 친절하게 되어있어 잘 읽고 따라하면 문제없이 세팅을 할 수 있을것이다.

### 0. Travis-ci?

Travis-ci 는 Github API 를 연동해서 Push 를 하거나, Pull request 를 받았을 때 전용 서버에서 빌드를 해주는 서비스로 활용 가치가 상당히 높다. 현재 내 블로그에는 업데이트 한 블로그 내용을 푸시 하면, Travis-ci 에서 컴파일 후 서비스 브랜치에 직접 푸시해주는 기능을 넣어놓았다.
위 방법은 [whiteglass][jekyll-whiteglass] 에서 쓰인 방식을 그대로 사용했다.

### 1. Github Repository -> Travis-ci 연동하기

연동하는 방법은 꽤 간단하다. 순서는 아래와 같다.

> 1. Travis-ci 에 Github 계정으로 로그인(반드시 계정이 있어야함.)
> 2. [Profile](https://travis-ci.org/profile) 에서 Travis-ci 를 사용할 레포지토리를 설정한다.
> 3. 로컬 저장소에서 .travis.yml 파일을 포함한 커밋을 푸시해준다.

위의 두가지 절차는 사이트 내에서 간단하게 처리가 가능하다. 하지만 세번째 사항은 가이드가 없으면 조금 헤멜 수도 있다.

### 2. Travis-ci -> Github Repository 자동 배포 시스템 만들기


## Code-clmiate 설정하기

## Coveralls 설정하기

# jekyll-sitemap 으로 구글 검색되게 하기

sitemap.xml
robots.txt
feed.xml

[github_com]: https://github.com/
[jekyll-home]: https://jekyllrb.com/
[jekyll-kr]: https://jekyllrb-ko.github.io/
[jekyll-theme]: htpps://jekyllthemes.org/
[jekyll-whiteglass]: https://github.com/yous/whiteglass
[disqus_home]: https://disqus.com/
