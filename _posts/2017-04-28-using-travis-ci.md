---
layout: post
author: "Su-hyeok Kim"
comments: true
categories:
  - makeblog
  - try
---

## Travis-CI : Continuous Intergration

다른 Github Repository 를 살펴보면서 많은 곳에서 Travis-CI 를 사용하고 있어 한번 시도해 보았다. 블로그를 만들기 이전부터 CI 에 대한 소식은 많이 들었지만 직접 사용해보는 것은 처음이였다. 약간 삽질을 했지만 영어만 읽을 줄 안다면 필요 없는 삽질이였다. 삽질할 때는 몰랐지만 Travis-CI 에서 제공하는 웹 문서들이 꽤 친절하게 되어있어 잘 읽고 따라하면 문제없이 세팅을 할 수 있을것이다. 물론 영어다.([Documentation](https://docs.travis-ci.com/))

Travis-ci 는 Github 과 연동하여 사용할 수 있는 CI 서비스다. Jenkins씨 처럼 직접 사용환경을 만드는게 아니기 때문에 상당히 편하다. 또한 Travis-ci 는 빌드스크립트를 사용해서 빌드를 해주기 때문에 처음 사용하기엔 약간 불편하지만 "스크립트" 이기 때문에 강력한 범용성을 가진다.

현재 이 블로그에서는 Travis-ci 를 통해 유효성을 검증한 후에 실제 서비스하는 브랜치로 방법이 Travis-ci 빌드스크립트에 적용되어 있다. [whiteglass](https://github.com/yous/whiteglass) 에 기본적으로 되어 있어 처음에는 의아했는데 꽤 괜찮은 아디이어여서 현재도 쓰고 있는 방법이다.

Travis-ci 를 연동하고 활용하는 방법에 대해서 알아보자.

<!-- more -->

## Github Repository -> Travis-CI 연동하기

세가지 세팅이 필요하다. 저장소의 루트 디렉토리에 .travis.yml 의 이름을 가진 빌드스크립트를 넣어주어야 하고, [https://www.travis-ci.org/](https://www.travis-ci.org/) 에 들어가 Github 계정으로 로그인 후 Travis-ci 사용 설정을 해주고, Travis-ci 홈페이지에 가서 사용 설정을 해주면 된다. [https://www.travis-ci.com/](https://www.travis-ci.com/) 은 결제가 필요한 Pro 기능이니 결제할게 아니면 [https://www.travis-ci.org/](https://www.travis-ci.org/) 로 들어가라.

Travis-ci 전용 빌드 스크립트는 무조건  .travis.yml 이여야 하고, 파일의 위치는 루트에 있어야 한다. 즉 경로로 따지만 "/.travis.yml" 이런 식이 되겠다. 그리고  자세한 내용은 원하는 플랫폼, 언어의 만들어진 예제를 보는게 빠를것이다. 커맨드 라인으로 컴파일을 하는 과정을 써야 하므로 플랫폼마다 다르다. [Travis-CI : customizing the build](https://docs.travis-ci.com/user/customizing-the-build/) 에서 빌드 파이프 라인등 여러가지 내용을 확인할 수 있다.

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

## 빌드스크립트를 활용한 자동 배포 시스템 만들기

간단하게 활용하는 방법에 대해서 알아볼텐데 빌드 스크립트를 활용하여 Travis-CI 에서 빌드가 끝나면 Github 레포지토리에 푸시하는 스크립트를 만드는 방법에 대해서 알아볼 것이다.

우선 Travis-CI 전용 빌드스크립트를 사용할려면 _Build Life Cycle_ 에 대하여 알아야 한다. [Travis-CI : customizing the build](https://docs.travis-ci.com/user/customizing-the-build/) 를 보면 바로 밑에 _Build Life Cycle_ 항목이 있을 것이다. 숫자가 쓰여있는대로 실행을 하는데 실행 과정은 한번을 빼고는 전부 선형적으로 되어있다.

> 1. OPTIONAL Install apt addons
> 2. OPTIONAL Install cache components
> 3. before_install
> 4. install
> 5. before_script
> 6. script
> 7. OPTIONAL before_cache (for cleaning up cache)
> 8. after_success or after_failure
> 9. OPTIONAL before_deploy
> 10. OPTIONAL deploy
> 11. OPTIONAL after_deploy
> 12. after_script

위 과정에서 OPTIONAL 을 제외한 과정들이 주가되는 빌드 과정인데 before_install 과 install 에서는 본격적인 빌드에 앞서 필요한 것들을 설정하는 과정이고, before_script 와 script 과정은 실제 빌드를 하는 과정이다. 이 과정들에서 실행시에 정상적이지 못한 실행이 되면(return 0 가 아닐 때) Travis-ci 는 이를 문제로 파악해 빌드를 멈추고 에러가 나거나, 실패한 것으로 간주한다.

그 이후의 after_success, after_failure 는 빌드가 성공하냐, 실패하냐에 따라 실행되는게 다른데 위에서 설명한 도중에 멈추었을 때 after_failure 에 있는것을 실행하고 문제없이 잘되면 after_success 에 있는 커맨드를 실행한다. 여기서는 빌드에서 상관없는 후처리를 하면 된다. 또한 여기서 비정상적인 종료는 그냥 넘어가게 된다. 그러니 중요한 빌드 과정은 위의 과정에 넣어두는게 좋다.

이제 실제 적용사례를 보자. 이 블로그의 예전 빌드스크립트를 확인해 볼것이다.

{% highlight shell %}
language: ruby
sudo: false
cache: bundler
rvm:
  - 2.3.3
before_install:
  - gem update --system
  - gem update --remote bundler
install:
  - bundle install --jobs=3 --retry=3 --path=${BUNDLE_PATH:-vendor/bundle}
before_script:
  - git config --global user.name "$(git --no-pager show --no-patch --format='%an')"
  - git config --global user.email "$(git --no-pager show --no-patch --format='%ae')"
script:
  - git clone -b master --depth 1 --quiet "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" \_site
  - rm -r \_site/*
  - bundle exec jekyll build
after_success:
  - cd \_site
  - git add -A
  - git commit -m "Updated to $(git rev-parse --short $TRAVIS_COMMIT) at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
  - git push -f "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" master --quiet
branches:
  only:
    - source
{% endhighlight %}

이 블로그는 _jekyll_ 을 기반으로 만들어져 있어 _jekyll_ 을 통해 빌드를 하면 기본적인 과정은 끝난다. _jekyll_ 의 기본 빌드 경로는 현재 디렉토리의 /\_site 다. 그래서 위의 빌드스크립트에서도 \_site 에서 무언가 많이 하는걸 볼 수 있는데, 중요한 것은 after_success 의 실행 커맨드다. 빌드가 끝난 후, 빌드 결과물이 있는 \_site 경로로 이동해(cd \_site) 모든 결과를 커밋해 푸시하는(이하 명령) 코드가 나와 있다.

그런데 이상한 환경변수가 하나 있을 것이다. _TOKEN_ 이라는 이상한 환경변수가 하나 있는데, 이는 Travis-CI 에다가 필자가 직접 설정한 환경변수다. 이 환경변수는 Github 에서 push 하는 클라이언트를 인증하기 위한 문자열인데 이에 대해서는 조금 자세한 설명이 필요하다.

Github 과 통신할 때, 인증서를 이용해 인증하는 방식과 url 에 클라이언트 인증 토큰을 포함해 인증하는 두가지 방식이 있다. 그리고 Travis-CI 에서 보여지는 공식 문서에서는 총 4가지 방식으로 인증하는 방법에 대해 나와 있는데 두개는 인증서를 통해, 두개는 토큰을 통해 인증하는 방식이다. 그런데 인증서를 통한 방식 중 하나는 Travis-Pro 사용해야 가능하고, 하나는 Travis-CI 시스템에서 인증서 비밀번호를 입력하는 단계를 지나지 못해 포기했었다. 결국 토큰을 포함하는 방법을 사용하게 되었는데 토큰은 두가지 방식으로 구성이 가능하다. 하나는 사용자의 아이디와 패스워드를 직접 url 에 넣는 방법과 하나는 사용자 계정에 설정된 토큰을 이용하는 방법이다. 직접 패스워드와 아이디를 설정하는 방법은 누가 봐도 상당히 문제가 있어보이기 때문에 사용자 토큰을 통해 인증하는 방식을 택했다. 인증에 대한 자세한 내용은 여기에 있다. [Travis-CI : private dependencies](https://docs.travis-ci.com/user/private-dependencies/)

우선 사용자 토큰을 사용할려면 발급을 받아야 한다. Github -> Settings -> Personal access tokens 으로 들어가면 화면 상단에 아래와 같은 그림이 나올 것이다.

![Github Personal access tokens](/images/personal_access_tokens.png)

여기에는 자신의 Github 개인정보를 사용할 수 있는 토큰들이 발급된 리스트를 볼 수 있는데, 이상한게 있으면 지우는게 신상에 좋을 것이다. 그래서 우리는 새로 쓰일 토큰을 발급받아야 하기 때문에 상단에 있는 Generate new token 이라는 버튼을 눌러 만들면 된다. 한번 비밀번호 인증이 필요할 것이다. 토큰의 이름을 설정해주고 _repo_ 라고 써있는 상위 항목을 선택해준 뒤 만들면 된다. 계정 접근 권한을 선택하는 것이니 나머지는 안건드리는게 좋을 것이다. 그렇게 만들면 끝이 아니라, 만든 후에 다시 Personal access tokens 메뉴로 가게 되는데 여기서 새로 만든 토큰 문자열이 나온다. 딱 한번만 나오니 토큰을 까먹었다면 다시 해당 토큰으로 들어가 재발급 받아야 한다.

이제 토큰을 얻었으니 Travis-CI 에 설정된 레포지토리 환경설정 정보에 업데이트를 해주면 된다.

![Travis-CI my repo](/images/Travis-CI_myblog_repo.png)

설정할 레포지토리 정보에 들어가면 위와같이 레포지토리 이름과 여러 정보들을 선택할 수 있는 메뉴가 나오는데, 오른쪽 상단에 _More Option_ 을 선택해 Settings 메뉴로 간다. 들어가면 조금 밑에 _Environment Variables_ 공간이 있는데 여기에 아까 환경변수 이름과 똑같이(_TOKEN_) 써주고 토큰 값을 복사+붙여넣기 한 후 ADD 버튼을 눌러주면 토큰 설정은 끝이다.

![Travis-pro authorize](/images/travis-ci_env_settings.png)

이렇게 설정을 하면 after_success 이후의 명령들을 잘 실행될 것이다. _TRAVIS_REPO_SLUG_ 라는 환경변수도 있는데 이는 Travis-CI 에서 지원하는 환경 변수다. 링크를 참조하라. ([링크](https://docs.travis-ci.com/user/environment-variables/))

# 참조

- [jekyll 테마 : whiteglass](https://github.com/yous/whiteglass)
- [Travis-CI : customizing-the-build](https://docs.travis-ci.com/user/customizing-the-build/)
- [Travis-CI : environment-variables](https://docs.travis-ci.com/user/environment-variables/)
