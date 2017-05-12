---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - git
  - merge
  - unity
---

꽤 많은 사람들이 Git 을 사용한다. SVN 보다 더 널리 알려지고 유용하게 쓰이는 VCS 로써 굉장히 많이 쓰이는 시스템이다. Unity 를 사용할 때도 Git 을 이용해 버젼 관리를 할 수 있는데, 아무런 세팅없이 사용하기엔 조금 문제가 있다. 보통 대두되는 문제는 두가지다.

첫번째는 Git 을 쓰다보면 느끼게 되는데, Git 자체는 텍스트로 구성된 데이터를 취급하려고 만들어졌기 때문에 바이너리 데이터에 대한 솔루션이 없었다. 만약 큰 바이너리 파일이 존재하면 커밋마다 계속 스냅샷을 갱신하기 때문에 커밋에 쓰이는 데이터는 기하급수적으로 늘어나게 된다. 보통 텍스쳐나 영상을 가지고 있게 되면 위의 상황에 부딫친다. 두번째는 조금 귀찮은 경우다. Unity 는 자체적으로 여러 데이터들의 확장자를 지정하여 파일을 사용하는데 커밋을 병합(merge) 할 때 Unity 에서 지원하는 파일에 충돌이 생겨 직접 손봐주어야 할 때, 일정 형식에 맞추지 않으면 끔찍한 사태가 일어나게 된다. 문제가 대표적으로 생기는 파일은 씬(.scene) 파일이다.

여러가지 세팅을 해주어야 하니 차근차근 살펴보자.

<!-- more -->

# Unity 프로젝트 설정하기

우선 외부 파일을 세팅하기전에 Unity 프로젝트에서 간단한 세팅을 해주어야 한다. 우선 상위 메뉴의 Edit -> ProjectSettings -> Editor 를 선택해 Inspector 창을 보자. 아래 방법을 따라하면 된다.

![Unity Go to editor](/images/unity-edit-ps-editor.png){: .center-image }

그러면 여러 설정이 뜨는데 여기서 두가지면 살펴보면 된다. 첫번째는 Version control 이라는 항목이다. 이 항목은 VCS 을 설정하거나 Unity 에서 .meta 파일을 사용해 데이터를 저장하는 두가지의 큰 방식으로 나뉘는데 Unity Personal 에서는 VCS 를 설정하는 것은 사용할 수 없다. 그러므로 Personal 라이센스 사용자는 결국 두가지 방식 중 하나만 고르면 된다. .meta 파일을 숨김파일로 지정하느냐 일반 파일로 지정하느냐의 차이인데 Git 에서는 숨김 파일은 취급하지 않기 때문에 Visible Meta Files 옵션을 사용한다.

![Unity VCS Setting](/images/unity_editor_version_control.png){: .center-image }

두번째는 Asset Serialization 이라는 항목이다. 이 옵션은 Unity 프로젝트에서 Unity 에서 직접 지정하는 확장자가 붙은 파일들을 어떻게 취급하냐를 설정하는 옵션이다. Unity 프로젝트에서는 두가지 방식으로 파일을 취급할 수 있는데 하나는 텍스트 형식으로 취급하는 것과 하나는 바이너리 형식으로 취급하는 것이다. 옵션의 선택지를 보면 총 3가지 인데 맨처음 Mixed 는 Unity 에서 파일마다 지정한 방식대로 텍스트냐 바이너리냐를 따라가는 것이고 나머지 두개(Force Text, Force Binary)는 무조건 한가지 방식으로 모든 파일들을 통일하는 것이다. 여러 용도로 텍스트를 사용하므로 Force Text 옵션을 사용한다.

![Unity Asset Serialization](/images/unity_editor_asset_serialization.png){: .center-image }

여기까지 Unity 프로젝트에서 설정해주어야 하는 것들은 끝이다. 다음은 외부에서 설정해주어야 하는 것들을 살펴보자.

# Git 설정 파일 추가하기

Git 에서는 여러 방식의 설정을 지원한다. 그 중에서도 우리는 많이 쓰이는 두가지 방식의 설정에 대해서 알아볼 것이다. 두가지 방식 모두 파일에 설정 정보를 저장한 후 해당 파일이 스테이징 공간에 들어가게 되면 로컬 레포지토리에 바로 적용된다. 보통은 맨 처음 커밋에 넣어주어 앞으로의 커밋들에 대비한다.

## 스테이징 공간의 이름 필터 : .gitignore

Git 에서 새로운 커밋을 만들 때, 파일들을 임시로 담아놓는 공간이 있다. 이 공간을 스테이징 영역이라 하는데 Git 로컬 레포지토리에 등록되어 있고 내용이 변경된 파일이나, 아예 등록되지 않은 파일을 넣어서 커밋으로 만드는 임시 공간이다. 비유를 하자면 장바구니(stage area)에 미리 커밋할 것을 넣어놓고 사는(commit) 행위로 비유할 수 있겠다. 하여튼 스테이징 영역에서 무언가 필터 역할을 하는 특수 옵션 파일이 .gitignore 인데 무언가 무시한다는 것만 알 수 있다.

위 문단에서도 말했지만 스테이징 영역에 들어갈 수 있는 것들은 파일이 등록되어 변경된 파일이나, 아예 등록되지 않은 파일인데 .gitignore 안에 패턴에 해당되고, 로컬 레포지토리 안에 등록되지 않은 파일은 스테이징 영역의 후보에서도 아예 사라진다. 즉 패턴을 .gitignore 파일안에 등록하면 앞으로 등록되지 않은 파일 중에 패턴에 맞는 파일들은 스테이징 영역에도 저장할 수 없다. 더 쉽게 말하자면 어떤 특정한 이름을 가지면 아예 커밋을 못하게 할 수 있다는 것이다.

Unity 프로젝트에서 아주 중요한 패턴이 몇개 있다. 이를 예로 보자.

> Library/\*
> \*/Library/\*
> Temp/\*
> \*/Temp/\*

위 예시들은 Unity 프로젝트에서 Git 리모트 레포지토리에 보내면 안되는 부모 디렉토리 이름들이다. Library 디렉토리는 프로젝트의 캐시 데이터로써 프로젝트를 실행하려면 Unity 에서 계산을 해서 만드는 파일이지만 굳이 없어도 알아서 만들어지기에 꼭 필요는 없는 파일이다. 자세한 사항은 [링크]({{ site.baseurl }}{% post_url 2017-04-02-unity-project-directory-structue %})에서 확인하라. * 의 뜻은 앞에 적어도 한개 이상의 아무 글자가 있어야 한다는 뜻이다. 즉 Library 디렉토리의 하위의 파일들을 포함한다는 뜻이고, .gitignore 파일안에 있으니 하위의 파일들을 전부 제외한다는 뜻이다.

이런 여러 패턴들을 저장해 쓸데없는 파일들을 스테이징 영역에 들어갈 후보에서 제외해 편하게 스테이징 작업을 할 수 있게 해준다. 거의 모든 프로젝트에서 메타파일들을 제외하기 위해 쓴다. 그만큼 굉장히 유용한 옵션이다. 그리고 굳이 하나하나 패턴을 추가해줄 필요 없이 자동으로 패턴을 가져올 수 있는 사이트가 있다. 바로 [https://www.gitignore.io/](https://www.gitignore.io/) 다. 여러 플랫폼을 설정해줄 수 있으니 사용하는 것에 따라 다르게 설정해주면 된다.

## 디렉토리별 속성 지정 : .gitattributes

Git 시스템은 텍스트 파일을 기준으로 만들어져 있다고 위에서 설명했었다. 그래서 파일을 병합(merge)를 할때나 비교(diff) 할 때 바이너리 파일이면 문제가 있다고도 말했다. .gitattributes 는 디렉토리나 파일 단위로 Git 에서 설정한 것과 다른 설정을 할수도 있다. 파일이 위치하는 디렉토리부터 병합 도구(mergetool)과 비교 도구(difftool) 을 확장자별로 설정할 수도 있고, 파일의 유형을 설정해서 Git 시스템이 다르게 동작하게도 할 수 있다. 즉 디렉토리별로 설정을 하는 방법이라 보면 될듯하다.

갑자기 .gitattributes 에 대해 설명을 하는 이유는 .gitattributes 에 Unity 에서 사용하는 전용 파일이나 용량이 큰 텍스쳐, 사운드, 영상 파일을 따로 효율적으로 관리할 수 있기 때문이다. [링크](https://gist.github.com/nemotoo/b8a1c3a0f1225bb9231979f389fd4f3f) 에 쓰여있는 내용을 조금 잘라서 확인해보자. 실제 파일로도 직접 사용하면 된다.

> ...
>
> \*.unity merge=unityyamlmerge eol=lf
>
> \*.prefab merge=unityyamlmerge eol=lf
>
> ...
>
> \*.jpg filter=lfs diff=lfs merge=lfs -text
>
> \*.jpeg filter=lfs diff=lfs merge=lfs -text
>
> ...

위 텍스트는 Unity 프로젝트에서 사용하는 .gitattributes 파일 내용의 일부분이다. 다만 다른 내용은 없고 전부 중복되는 내용이기에 일부분만 가져왔다. 여기서도 \* 을 사용해 파일의 패턴을 표현했다. .gitattributes 에서는 전부 확장자만 체크를 해서 파일의 타입을 지정했다. 여기서 지정한 파일의 타입은 두가지로 나뉘는데 Unity 에서 사용하는 파일의 확장자와 큰 크기의 파일 확장자를 지정해 주었다. Unity 에서 지정한 파일 확장자는 병합(merge)시에 사용하는 툴을 git 기본 mergetool 이 아닌 Unity 에서 기본으로 지원해주는 UnityYAMLMerge 라는 커맨드라인 툴을 사용하도록 지정하고 추가로 줄끝을 어떻게 구분하는지 옵션값을 넣어준다. 큰 크기의 파일 확장자는 기본 병합 도구와(mergetool) 비교 도구(difftool) 그리고 필터라는 것을 lfs 라는것으로 전부 설정해 주었다. lfs 라는 것은 큰 크기의 파일을 취급하는 것이다. 정확히는 매 커밋마다 큰 파일을 가지고 있는 것이 아니라 큰 파일의 포인터를 저장해서 변경시에만 새로운 파일을 저장한다.

이렇게 파일을 설정하면 끝이라고 생각하겠지만 아직은 아니다. 위에서 설정한 UnityYAMLMerge 와 LFS 정보를 설정시켜주어야 한다. [링크](https://docs.unity3d.com/Manual/SmartMerge.html) 에서 UnityYAMLMerge 의 정보를 설정시켜주는 방법이 나온다.

> [mergetool "unityyamlmerge"]
>
> trustExitCode = false
>
> cmd = "path to UnityYAMLMerge" merge -p "$BASE" "$REMOTE" "$LOCAL" "$MERGED"

위의 텍스트를 사용자 홈 디렉토리에 존재하는 .gitconfig(--global) 에 직접 위와같이 써넣거나 bash 에서 직접 설정해주면 된다. 중간에 _"path to UnityYAMLMerge"_ 는 설치된 Unity 디렉토리 안에 "/Editor/Data/Tools/UnityYAMLMerge.exe" 위치에 있다. 그리고 기본으로 쓰는 merge.tool 정보는 바꾸지 않는다. .gitattributes 에서 확장자별로 바꿔주기 때문에 굳이 쓰지 않는다.

LFS 의 설정방법은 매우 단순하다. [링크](https://git-lfs.github.com/)에서 설치파일을 받아서 설치를 완료하면 알아서 설정을 해준다. 굉장히 편하다. 'git config --system --list' 명령어로 lfs 가 설정된 것을 확인할 수 있다.

![Git config for lfs](/images/gitconfigsystem.png){: .center-image }

여기까지 두가지 옵션을 설정하는 방법에 대해서 알아보았다. UnityYAMLMerge 와 LFS 설정이 되어 있으면 [.gitattributes](https://gist.github.com/nemotoo/b8a1c3a0f1225bb9231979f389fd4f3f) 와 [.gitignore](https://www.gitignore.io) 파일만 Git 시스템에 넣어주면 앞으로 편하게 설정이 가능하다. 파일을 구할 수 있는 링크를 이름에 넣어놓았으니 직접 받아서 가져가면 된다.

## 참조

- [www.gitignore.io](https://www.gitignore.io)
- [Gist : Unity .gitattributes](https://gist.github.com/nemotoo/b8a1c3a0f1225bb9231979f389fd4f3f)
- [Git-lfs](https://git-lfs.github.com/)
- [Unity ref : SmartMerge](https://docs.unity3d.com/Manual/SmartMerge.html)
- [git-scm : .gitattributes](https://git-scm.com/book/ko/v2/Git%EB%A7%9E%EC%B6%A4-Git-Attributes)
