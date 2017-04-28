---
layout: post
author: "Su-hyeok Kim"
comments: true
categories:
  - jekyll
  - makeblog
  - try
---

## Travis-ci : Continuous Intergration

다른 Github Repository 를 살펴보면서 많은 곳에서 Travis-ci 사용하고 있어 한번 시도해 보았다. 블로그를 만들기 이전부터 CI 에 대한 소식은 많이 들었지만 직접 사용해보는 것은 처음이였다. 약간 삽질을 했지만 영어만 읽을 줄 안다면 필요 없는 삽질이였다. 삽질할 때는 몰랐지만 Travis-ci 에서 제공하는 웹 문서들이 꽤 친절하게 되어있어 잘 읽고 따라하면 문제없이 세팅을 할 수 있을것이다. 물론 영어다.([Documentation](https://docs.travis-ci.com/))

Travis-ci 는 Github 과 연동하여 사용할 수 있는 CI 서비스다. Jenkins씨 처럼 직접 사용환경을 만드는게 아니기 때문에 상당히 편하다. 또한 Travis-ci 는 빌드스크립트를 사용해서 빌드를 해주기 때문에 처음 사용하기엔 약간 불편하지만 "스크립트" 이기 때문에 강력한 범용성을 가진다.

현재 이 블로그에서는 Travis-ci 를 통해 유효성을 검증한 후에 실제 서비스하는 브랜치로 방법이 Travis-ci 빌드스크립트에 적용되어 있다. [whiteglass](https://github.com/yous/whiteglass) 에 기본적으로 되어 있어 처음에는 의아했는데 꽤 괜찮은 아디이어여서 현재도 쓰고 있는 방법이다.

Travis-ci 를 연동하고 활용하는 방법에 대해서 알아보자.

### 1. Github Repository -> Travis-ci 연동하기

두가지 세팅이 필요하다. 저장소의 루트 디렉토리에 .travis.yml 의 이름을 가진 빌드스크립트를 넣어주어야 하고, [https://www.travis-ci.com/](https://www.travis-ci.com/) 에 들어가 Github 계정으로 로그인 후 세팅을 해주면 끝이다.

Travis-ci 전용 빌드 스크립트는 무조건 이름이 .travis.yml 이여야 하고, 파일의 위치는 루트에 있어야 한다. 즉 경로로 따지만 "/.travis.yml" 이런 식이 되겠다.

[whiteglass](https://github.com/yous/whiteglass) 에 있는 .travis.yml 의 내용을 확인해보겠다.

{% highlight shell lineos %}
language: ruby
sudo: false
cache: bundler
rvm:
  - 2.3.3
before_install:
  - gem update --system
  - gem update --remote bundler
before_script:
  - git config --global user.name "$(git --no-pager show --no-patch --format='%an')"
  - git config --global user.email "$(git --no-pager show --no-patch --format='%ae')"
script:
  - git clone -b gh-pages --depth 1 --quiet "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" \_site
  - rm -rf \_site/*
  - bundle exec jekyll build
after_success:
  - cd \_site
  - git add -A
  - git commit -m "Updated to $(git rev-parse --short $TRAVIS_COMMIT) at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
  - git push "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" gh-pages --quiet
branches:
  only:
    - master

{% endhighlight %}

[Travis-CI : customizing-the-build](https://docs.travis-ci.com/user/customizing-the-build/)

<!--
  github 로그인
-->

### 2. Travis-ci -> Github Repository 자동 배포 시스템 만들기


## Code-clmiate 설정하기

## Coveralls 설정하기

# jekyll-sitemap 으로 구글 검색되게 하기

sitemap.xml
robots.txt
feed.xml

# 참조

- [Travis-ci : Buildscript 파이프라인](https://docs.travis-ci.com/user/customizing-the-build/)
- [jekyll 테마 : whiteglass](https://github.com/yous/whiteglass)
