---
layout: post
author: "Su-hyeok Kim"
comments: true
categories:
  - makeblog
  - try
---

## Travis-ci : Continuous Intergration

다른 Github Repository 를 살펴보면서 많은 곳에서 Travis-ci 사용하고 있어 한번 시도해 보았다. 블로그를 만들기 이전부터 CI 에 대한 소식은 많이 들었지만 직접 사용해보는 것은 처음이였다. 약간 삽질을 했지만 영어만 읽을 줄 안다면 필요 없는 삽질이였다. 삽질할 때는 몰랐지만 Travis-ci 에서 제공하는 웹 문서들이 꽤 친절하게 되어있어 잘 읽고 따라하면 문제없이 세팅을 할 수 있을것이다. 물론 영어다.([Documentation](https://docs.travis-ci.com/))

Travis-ci 는 Github 과 연동하여 사용할 수 있는 CI 서비스다. Jenkins씨 처럼 직접 사용환경을 만드는게 아니기 때문에 상당히 편하다. 또한 Travis-ci 는 빌드스크립트를 사용해서 빌드를 해주기 때문에 처음 사용하기엔 약간 불편하지만 "스크립트" 이기 때문에 강력한 범용성을 가진다.

현재 이 블로그에서는 Travis-ci 를 통해 유효성을 검증한 후에 실제 서비스하는 브랜치로 방법이 Travis-ci 빌드스크립트에 적용되어 있다. [whiteglass](https://github.com/yous/whiteglass) 에 기본적으로 되어 있어 처음에는 의아했는데 꽤 괜찮은 아디이어여서 현재도 쓰고 있는 방법이다.

Travis-ci 를 연동하고 활용하는 방법에 대해서 알아보자.

<!-- more -->

### 1. Github Repository -> Travis-CI 연동하기

세가지 세팅이 필요하다. 저장소의 루트 디렉토리에 .travis.yml 의 이름을 가진 빌드스크립트를 넣어주어야 하고, [https://www.travis-ci.org/](https://www.travis-ci.org/) 에 들어가 Github 계정으로 로그인 후 Travis-ci 사용 설정을 해주고, Travis-ci 홈페이지에 가서 사용 설정을 해주면 된다.

Travis-ci 전용 빌드 스크립트는 무조건   .travis.yml 이여야 하고, 파일의 위치는 루트에 있어야 한다. 즉 경로로 따지만 "/.travis.yml" 이런 식이 되겠다. 그리고  자세한 내용은 원하는 플랫폼, 언어의 만들어진 예제를 보는게 빠를것이다. 커맨드 라인으로 컴파일을 하는 과정을 써야 하므로 플랫폼마다 다르다. [Travis-CI : customizing the build](https://docs.travis-ci.com/user/customizing-the-build/) 에서 빌드 파이프 라인등 여러가지 내용을 확인할 수 있다.

다음은 Travis-CI 사이트에 가입 후 Travis-CI 에서 Github 계정으로 로그인을 해주어 API 의 접근을 허가받으면 된다. [https://www.travis-ci.org/](https://www.travis-ci.org/) 들어간다. [https://www.travis-ci.com/](https://www.travis-ci.com/) 은 유료인 Travis-Pro 버젼 사이트이니 구분해서 들어가도록 한다. 나는 무료인 [https://www.travis-ci.org/](https://www.travis-ci.org/) 으로 들어가겠다.

![Travis-CI home](/images/travis_ci_home.png)

사이트로 들어가면 오른쪽 상단에 Github 계정으로 로그인 하는 버튼과 중간에 가입하는 버튼이 있다,

[Travis-CI : private dependencies](https://docs.travis-ci.com/user/private-dependencies/)

버튼을 눌러 Github 로그인을 하게되면 아래와 비슷한 화면이 나온다. 필자는 이미 가입해서 잘쓰고 있어 Travis-Pro 로 스크린샷을 찍었다.

![Travis-pro authorize](/images/authorize_application.png)

위 과정에서 승인을 해서 authorize 즉 승인을 하게되면 Travis-CI 의 기능을 사용할 수 있게 된다.

이제 Github API 사용 권한을 얻었으니 Travis-CI 홈페이지에 가서 어떤 레포리토리가 사용을 할 것인지 체크해주면 된다. 정말 쉽다. 홈페이지에 들어가서 우측 상단의 이름을 선택 후 나오는 Accounts 메뉴로 들어간다.

![Travis-CI homepage upper](/images/travis_ci_homepage.png)

저 메뉴로 들어가면 본인의 레포지토리 리스트가 나올것이다. 나오지 않는다면 우측 상단에 Sync account 를 눌러주면 된다. Travis-CI 를 사용할 레포지토리를 토글해서 사용 표시 해놓으면 사용 준비는 끝이다.

![Travis-CI my accounts](/images/travis_ci_my_accounts.png)

위의 사진은 필자의 Travis-CI 설정 화면이다. 여기까지 설정을 한 후 해당 레포지토리에 푸쉬를 하면 알아서 트리거가 되어 빌드 스크립트에 적힌대로 빌드를 실행한다. 

### 2. Travis-CI -> Github Repository 자동 배포 시스템 만들기

### 3. 다른 플러그인 설정하기

## Code-clmiate 설정하기

## Coveralls 설정하기

## jekyll-sitemap 으로 구글 검색되게 하기

sitemap.xml
robots.txt
feed.xml

# 참조

- [Travis-ci : Buildscript 파이프라인](https://docs.travis-ci.com/user/customizing-the-build/)
- [jekyll 테마 : whiteglass](https://github.com/yous/whiteglass)
