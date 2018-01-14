---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
---

Unity 의 에디터 시스템은 꽤나 유연하다. 이번 글에서는 _AssetImporter_ 에 대한 기능들에 대하여 알아볼 것이다.

Unity 의 각각의 Asset 들은 확장자의 이름에 따라서 _AssetImporter_ 가 하나씩 만들어지고, 해당 _AssetImporter_ 에 따라서 _Post-Process_ 가 진행된다. 필자가 많이 봤던 _AssetImporter_ 는 [_TextureImporter_](https://docs.unity3d.com/ScriptReference/TextureImporter.html) 와 [_ModelImporter_](https://docs.unity3d.com/ScriptReference/ModelImporter.html) 가 있었다. 확인할 당시에는 당연히 _AssetImporter_ 를 커스터마이징 할 수 있겠다는 생각이 들어 찾아봤지만 전혀 없었다.(Unity 5 버젼을 사용할 때다.) 이렇게 시스템을 만들어 놓고 왜 없냐는 의문이 들었지만 이는 정말 할수있는게 없었기에 넘어갔었다.

그런데 이번에 Unity 2018.1 베타가 릴리즈 되면서 SRP 를 살펴보던 도중 _Expremental_ 기능들 중에 [_ScriptedImporter_](https://docs.unity3d.com/2018.1/Documentation/Manual/ScriptedImporters.html) 라는 기능이 있는 것을 발견했다.

이 기능은 말그대로 예전의 내가 원하던 기능이였다. _AssetImporter_ 클래스와 다른점은 딱 한가지다. 가상 _OnImportAsset_ 메소드가 존재하는 것이다. 즉 _ScriptedImporter_ 를 상속하여 _OnImportAsset_ 를 구현하면 간단하게 에셋을 _Customize_ 할 수 있는 것이다. 또한 에디터 기능을 지원하는 [ScriptedImporterEditor ](https://docs.unity3d.com/2018.1/Documentation/ScriptReference/Experimental.AssetImporters.ScriptedImporterEditor.html) 라는 클래스를 사용하면 에디터를 손쉽게 바꿀 수 있다. 자세한 사항은 글에서 언급된 링크를 통해 보면 된다.

## 참조
 - [Unity Documentation : ScriptedImporter ](https://docs.unity3d.com/2018.1/Documentation/Manual/ScriptedImporters.html)
 - [Unity Reference : ScriptedImporter](https://docs.unity3d.com/2018.1/Documentation/ScriptReference/Experimental.AssetImporters.ScriptedImporter.html)
 - [Unity Reference : ScriptedImporterEditor ](https://docs.unity3d.com/2018.1/Documentation/ScriptReference/Experimental.AssetImporters.ScriptedImporterEditor.html)
