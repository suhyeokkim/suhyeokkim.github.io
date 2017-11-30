---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
    - jekyll
    - makeblog
---

아는 지인이 좋다고 추천해서 jekyll+github 으로 블로그를 만들게 되었다.
한글로 된 자료가 그리 많지 않아 직접 기록해보려 한다.

## 개요

원리는 간단하다. GitHub 에서 jekyll 로 만들어진 블로그 백엔드 서비스(BaaS)를 지원하고, 사용자는 일정한 형식으로 레포지토리를 구성하면 블로그가 짠! 하고 나타난다.
<!-- more -->
## GitHub 에서 작업할 것들

순서는 아래와 같다.

> 1. GitHub 계정이 없을 시 가입하기
>
> 2. GitHub 에 블로그 레포지토리 만들기

### GitHub 가입하기

![Github.com](/images/github_homepage_signup.png)

[Github.com][github_com]에서 가입하면 된다. 가입 절차는 간단하니 직접 해보라.

### GitHub 에 블로그 레포지토리 만들기

하나의 저장소를 만든다. 이때 중요한 것은 레포지토리 이름을 반드시 "__\(닉네임\)__.githum.com" 으로 적어주여야 한다.

![make_repo](/images/github_make_repo.png)

위와 같이 말이다. 우리는 원격 블로그 저장소를 만들었다. 이제 저장할 블로그 내용물을 만들 차례다.

## 블로그 만들기

Github 에서는 Ruby 로 만들어진 Jekyll 프레임워크 기반의 블로그를 지원한다. 즉 Jekyll 로 블로그를 만들어 GitHub 레포지토리에 올리면 잘 보인다. 만들어진 GitHub 레포지토리를 들어가보면 기본적으로 만들어진 블로그가 있다. 포스팅이 가능하고 기본적인 정보를 올릴 수 있다.

하지만 이 블로그는 만들어진 테마를 가져와서 세팅하는 것이기 때문에 내 멋대로 커스터마이징이 힘들다. 그렇다고 직접 스킨을 만들기에는.. 아무것도 모르는 사람이 처음부터 직접 만들기는 힘들다. 그러면 다른 사람이 만들어진걸 가져다 쓰는게 가장 빠르고 간편한 방법이다.

### 만들어진 테마 가져오기

우선 [jekyll 테마 홈페이지][jekyll-theme]이나 github에서 민들어진 jekyll 테마들을 찾아볼 수 있다. github 에서 가져오거나, [jekyll 테마 홈페이지][jekyll-theme]에서 직접 파일을 받아 쓸 수 있다.

#### 1. GitHub 에서 테마 가져오기

여러 방법이 있지만 필자는

> 1. clone 해서 로컬 저장소를 만든다.
>
> 2. 연결된 remote repository 를 블로그 repository 로 바꾼다.

위 방식으로 진행했다.

GitHub 에서 원하는 jekyll 테마를 clone 해준다. 이 글을 쓸 무렵 필자는 [whiteglass][jekyll-whiteglass] 테마를 사용했었다.

![whiteglass_theme](/images/github_jekyll_whiteglass_theme.png)

> git clone {other's url}

위의 그림의 위치에서 url 을 복사해 세팅할 디렉토리에 위와 같이 입력해주면 된다.

clone 을 한 후에는 가져온 remote repository 가 연결되어 있을 것이다. 일단 확인부터 해보자. 우선 프로젝트 루트 디렉토리로 이동해 shell 을 키고 아래 커맨드를 입력한다

{% highlight shell %}
git remote -v
{% endhighlight %}

그럼 아마도 아래와 같이 나올것이다.

> origin (other's-url) (fetch)
>
> origin (other's-url) (push)

잘 살펴보면 알겠지만 중간에 들어간 url 은 가져온 프로젝트의 url 이다. 변경하려면 다음과 같이 하면된다

{% highlight shell %}
git remote remove origin // 등록된 origin을 지운다.
git remote add origin (repository-url) // 본인 블로그 레포지토리 url 을 등록시켜 준다.
{% endhighlight %}

그 다음 다시 등록된 remote repository 를 확인해보자.

{% highlight shell %}
git remote -v
{% endhighlight %}

등록한 url 로 나오면 성공이다. 이제 연결을 해주었으니 원할 때 remote repository 로 보내면 된다.

정석인 방법은 원본 프로젝트를 fork 해서 나의 레포지토리로 바꾼 후 수정을 거쳐 하는것이지만, 언제 스킨을 바꿀지 모르기에 위 방식대로 진행했다.

#### 2. jekyll 테마 프로젝트를 구해서 설정하기

이 방법도 크게 다르지 않다. 단지 local repository의 설정이 다를뿐이다. 아래와 같이 진행하면 된다.

> 1. jekyll 테마 프로젝트의 루트 디렉토리에서 git 저장소로 설정한다.
>
> 2. 블로그 repository 를 remote repository 로 등록시켜 준다.

위 방식으로 진행했다.

프로젝트의 루트 디렉토리로 shell 을 이동해 아래와 같이 명령을 입력해준다.

{% highlight shell %}
git init
{% endhighlight %}

맨 처음 local repository로 설정해주는 명령어다. 인자가 따로 필요없이 그냥 저렇게만 쳐주면 된다.

기존에 연결된 remote repository 가 없으니 바로 remote repository 를 설정해주면 된다.

{% highlight shell %}
git remote add origin (repository-url) // 본인 블로그 레포지토리 url 을 등록시켜 준다.
{% endhighlight %}

여기까지 하면 local repository 를 설정하는건 끝이다.

### jekyll 개발환경 설정하기

테마까지 로컬 저장소에 설정을 해놓았으니 컴퓨터에서 가상의 서버를 돌려가면서 본인의 포스팅을 확인할 환경을 만들어 주어야 한다. 물론 세팅을 하지않고 포스팅을 할수는 있다. 변경하고 push 하고, 확인하고, 변경후 push하고 확인하는 루틴이 계속될 것이다.

하지만 위에서 말한 방법은 _매우_ 귀찮다. 쓰는대로 바로바로 진행이 되어야 편할 것이라 생각했기에 직접 jekyll 개발환경을 세팅하는 방향을 선택했다.

리눅스 계열 OS 를 사용하는 개발자들은 대부분 구버젼의 Ruby 가 깔려 있겠지만 Windows 환경에서는 전혀 그런게 없다. 그래서 필자는 직접 설치 해주었다. [Ruby installer][rubyinstaller-site] 사이트에 들어가면 간단하게 isntaller 만 받아 설치를 해줄 수 있다. 설치 과정 중 환경변수(Path) 설정하는 옵션을 설정하면 간단하게 사용이 가능하다.

이제 _bundler_ 라는 툴을 깔아주어야 한다. 쉘에서 많이 사용하며 Ruby 의 불편한 의존성 관리를 도와주는 툴이라고 한다. jekyll 에서는 기본적으로 _bundler_ 를 사용하기 때문에 꼭 설치해주어야 한다.

{% highlight shell %}
gem install bundler
{% endhighlight %}

이제 jekyll 만 깔아주면 개발 환경 구축은 끝이다. 아래 명령어를 입력하자.

{% highlight shell %}
gem install jekyll
{% endhighlight %}

### 로컬 환경에서 블로그 확인하기

모든 세팅이 다 끝났다면 이제 블로그를 직접 확인할 수 있다.

{% highlight shell %}
{% endhighlight %}
jekyll serve

위 명령어를 입력 후, 루프백 IP(127.0.0.1)나, localhost 도메인을 통해 블로그 서버를 직접 확인할 수 있다. 참고로 jekyll 은 4000 포트를 쓰니 참고 바란다.

[github_com]: https://github.com
[jekyll-theme]: https://jekyllthemes.org
[jekyll-whiteglass]: https://github.com/yous/whiteglass
[rubyinstaller-site]: https://rubyinstaller.org
