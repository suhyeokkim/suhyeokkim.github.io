---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
---

_Unity_ 에서는 모든 사용자의 작업물을 _Assets_ 폴더에 저장한다. 그리고 _Assets_ 폴더안의 파일의 변경이 발생할 시 안의 파일들을 재가공하여 다시 로드한다. 보통 파일의 변경은 _assetDatabaseX_ 바이너리 파일로 들어가게 되며, 스크립트, 바이너리의 변경은 다시 컴파일을 함으로써 현재 변경사항을 프로젝트에 적용시킨다.

이러한 시스템을 위해 _Unity_ 에서는 모든 파일, 디렉토리에 _meta_ 파일을 생성한다. 파일별 _meta_ 파일에는 해당 파일의 순수한 정보가 아닌 메타 정보가 들어간다. 중요한 정보는 두개로 나뉜다.

하나는 _Unity_ 프로젝트상에서 파일을 처음 감지했을 때, 파일의 _GUID_ 를 생성한다. _GUID_ 란 고유의 16진수 32글자로 이루어지는 총 512비트로 이루어지는 _ID_ 로써 자동으로 생성되는 알고리즘을 가지고 있으며 겹칠 염려는 거의 없는 _ID_ 알고리즘이다. 그래서 생성된 _GUID_ 는 다른 곳에서 해당 파일을 참조할떄 쓰인다. 즉 파일이 삭제되서 같은 것으로 다시 생성한다고 해도 _GUID_ 가 랜덤으로 결정되기 때문에 다시 연결을 해주어야 한다. 이는 _Unity_ 내부에서 파일 링크를 _GUID_ 로 한다는 추측을 할 수 있게 해준다. 또한 _Edit -> Project Setting -> Editor_ 에서 _Asset Serialization_ 모드가 _Force Text_ 로 되어있을 시에는 _meta_ 파일들을 직접 텍스트 에디터로 확인이 가능하다.

```
fileFormatVersion: 2
guid: 5d44a238286f6904198ab78e914c229d
MonoImporter:
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData:
  assetBundleName:
```

어떤 스크립트에 딸린 _meta_ 파일의 내용이다. 두번째 줄에 생성된 _guid_ 가 존재한다. 이는 _Library/metadata_ 디렉토리에 쓰여진 이름들과 매칭된다.

두번째는 바로 해당 파일의 _Importer_ 정보가 들어있다. 위의 _meta_ 파일은 스크립트이기 때문에 3번째 줄에 _MonoImporter_ 라고 쓰여져 있으며, 파일의 성질에 따라서 _built-in importer_ 가 달라진다. 바이너리 파일들은 _NativeImporter_, 텍스쳐 파일들은 _TextureImporter_, 3D 모델 파일들은 _ModelImporter_ 로 자동으로 매칭된다.

이러한 _Importer_ 정보들은 보통 해당 _Asset_ 의 옵션을 세팅할 떄 쓰인다. 또한 _2017_ 버젼에서는 파일의 확장자를 사용자가 직접 지정해 _Importer_ 를 사용할 수도 있게 해두었다.([링크]({{ site.baseurl }}{% post_url 2018-01-11-unity-scripted-importer %}))

즉 _Unity_ 에서는 새로운 파일을 감지했을 때, _GUID_ 를 생성하고 파일의 확장자에 따라 _Importer_ 정보를 갱신한 후, 정보를 _Library/metadata_ 에 갱신하는 것으로 볼 수 있다. _Library/metadata_ 에서는 _GUID_ 로 된 파일과 (해당 _GUID_).info 로 파일이 구성되어 있다. 각각의 파일은 파일의 유형별로 다른 것으로 보인다. 
