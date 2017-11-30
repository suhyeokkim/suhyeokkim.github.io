---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - rendering
  
---

Unity 에서는 Mesh 를 활용하기 위해 몇가지의 컴포넌트를 지원한다. 간단하게 알아보자.

### Mesh 를 가지고 있는 컴포넌트 : MeshFilter

이 컴포넌트는 Unity 컴퓨넌트가 아닌 __Mesh__ 클래스의 인스턴스를 가지고 있는 목적으로 만들어진 클래스다. __Mesh__ 의 인스턴스를 보관하고 외부에서 __Mesh__ 인스턴스에 접근할 수도 있다. 다만 조금 유의해야할 사항은 사용법이다. [MeshFilter](https://docs.unity3d.com/ScriptReference/MeshFilter.html) 문서를 보면 사용할 수 있는 프로퍼티가 두개가 있는데 하나는 _MeshFilter.sharedMesh_ 와 _MeshFilter.mesh_ 두개가 있다.  _MeshFilter.sharedMesh_ 는 실제 가지고 있는 __Mesh__ 인스턴스이고 _MeshFilter.mesh_ 는 원래의 인스턴스를 복사해 새로 생성한 것을 반환하기 때문에 주의해야 한다.

### Mesh 를 통해 그리는 컴포넌트 : MeshRenderer

__MeshRenderer__ 컴포넌트는 __Mesh__ 인스턴스와 등록된 Material 들을 통해 화면상에서 실제로 보여주는 역할을 하는 컴포넌트다. 같은 GameObject 안에 있는 __MeshFilter__ 를 통해 __Mesh__ 인스턴스에 접근한다. 또한 여러 옵션들을 통해 렌더링을 제어할 수 있다. 중요한 기능은 그림자를 받는 기능과 그림자를 생기게 하는 기능이다. 그 외에도 Unity 에서 지원하는 여러 옵션을 설정할 수 있다. 그리고 여러개의 __Material__ 들을 가지고 있을 수 있는데 __Mesh__ 의 _submesh_ 별로 __Material__ 을 매칭해주어야 알맞게 그릴 수 있다. 기본값은 한개이므로 특별히 세팅을 안했다면 한개씩만 넣어주면 된다.

### SkinnedMeshRenderer

위에서 설명한 __MeshRenderer__ 와 이름이 매우 비슷하다. 앞에 _Skinned_ 라는 키워드만 붙어있다. 이름은 비슷하지만 Unity 안에서 처리되는 것은 조금 다르다. __MeshRenderer__ 는 정점이 실시간으로 움직이지 않는 것들을 대상으로 그리는 컴포넌트다. 하지만 __SkinnedMeshRenderer__ 는 다르다. 이 컴포넌트도 __Mesh__ 를 그리기 위해 만들어진 컴포넌트지만 특정한 _Bone_ 을 기준으로 위치를 전부 계산하고 그려야 한다.

특정한 _Bone_ 을(Unity 에서는 Bone 한개마다 GameObject 하나로 나타낸다.) 기준으로 정점들을 움직이게 하게 해주는 작업을 _Rigging_ 이라고 하는데 _Rigging_ 이 적용된 것을 그릴려면 __SkinnedMeshRenderer__ 컴포넌트를 붙여 주어야 한다. __MeshRenderer__ 를 사용하면 _Bone_ 을 움직여도 움직임이 적용이 안된채로 그려져서 말짱 꽝이 되버린다.

### MeshCollider

충돌 감지를 __Mesh__ 를 활용해서 하는 컴포넌트로 일반적으로는 안쓴다. 폴리곤의 갯수가 많으면 많을수록 체크에 병목이 생기기 때문이다. 상황에 따라 폴리곤이 적은 경우에는 써도 무방하다. 이 컴포넌트는 생성될 때 __MeshFilter__ 컴포넌트가 존재하면 _sharedMesh_ 를 통해 __Mesh__ 인스턴스에 접근한다.

이렇게 __Mesh__ 를 활용하는 여러가지 컴포넌트들에 대하여 알아보았다. 할말은 많지만 간단한 소개를 위해 쓰여졌기에 여기까지 하겠다.

## 참조

- [Unity Manual - MeshFilter](https://docs.unity3d.com/kr/current/Manual/class-MeshFilter.html)
- [Unity Manual - MeshRenderer](https://docs.unity3d.com/kr/current/Manual/class-MeshRenderer.html)
- [Unity Manual - SkinnedMeshRenderer](https://docs.unity3d.com/kr/current/Manual/class-SkinnedMeshRenderer.html)
- [Unity ref - MeshFilter](https://docs.unity3d.com/ScriptReference/MeshFilter.html)
- [Unity ref - MeshRenderer](https://docs.unity3d.com/ScriptReference/MeshRenderer.html)
- [Unity ref - SkinnedMeshRenderer](https://docs.unity3d.com/kr/current/ScriptReference/SkinnedMeshRenderer.html)
