---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - rig
  - animate
  
---

앞서 오브젝트들을 그리는 방법에 대해서 알아보았다.([hnalding vertices]({{ site.baseurl }}{% post_url 2017-05-14-handling-vertices-and-indices-in-unity %}), [handling uvs]({{ site.baseurl }}{% post_url 2017-05-15-handling-uv-and-material-in-unity %})) 폴리곤을 그리고 색을 칠하는 방법이었다. 하지만 이런 기능만 가지고 게임을 만들기에는 약간 부족하다. 보통 게임을 만들때 케릭터들의 부드러운 움직임을 표현해야 한다. 2D 게임은 보통 그림을 여러장을 그려서 움직이게 보이게 한다. 하지만 3D 게임에서의 부드러운 움직임은 2D 게임의 표현과는 다르게 표현한다. 일단 부드럽게 움직여야할 단위가 다르다. 메쉬의 정점들을 부드럽게 움직여야하기 때문에 2D 게임의 움직임과는 다른 무언가가 필요하다.

2D 게임에서 그림을 한꺼번에 움직이는 것처럼 단순하게 메쉬 전체를 부드럽게 움직여서 해결되면 좋겠지만 이 방법은 조금 문제가 있다. 관절같은 접합 부분에서 부드럽게 처리해야 하는 부분 즉 어떤 정점만 부드럽게 움직여야하는 문제가 있다. 그래서 고안된 방법은 특정한 위치를 설정해서 그 위치를 기준으로 정점들을 움직여주는 방법이다.

언급한 특정한 위치를 _Bone_ : 뼈라고 한다. 뼈를 움직여서 정점들을 직접 움직이는 것이다. 그리고 뼈를 기준으로 움직이는 것을 _Skinning_ 이라고 한다. 사람의 뼈가 움직이면 피부도 따라서 움직이듯이 피부를 직접 설정하는 것을 _Skinning_ 이라고 하는 것이다. 그리고 _Bone_ 의 위치도 상당히 중요하다. 자연스러운 움직임을 만들려면 만들어진 메쉬에 잘 맞게 위치를 설정해주어야 하기 때문이다. 위치 뿐만아니라 여러 움직이는 범위나 뼈의 계층 구조를 잘 설정해주어야 자연스러운 움직임을 나타낼 수 있다. 이러한 작업을 _Rigging_ 이라 한다. 보통 3D 오브젝트를 만들고 _Rigging_ 과 _Skinning_ 을 하는 작업은 그래픽 아티스트가 직접 해주지만 우리는 이 과정을 이해해야 하기에 Unity 에서 직접 만들어 볼 것이다.

<!-- more -->

## Unity 에서 직접 리깅, 스키닝하기

일반적으로 저장된 메쉬에 _Rigging_, 뼈를 위치시키고 기타 설정을 하는 작업을 먼저한다. 그리고 뼈를 전부 위치시킨 다음 정점들과 뼈 사이의 가중치를 주는 _Skinning_ 작업을 한다. 우리도 이 순서에 맞게 작업을 할 것이다. [3DBasicExample](https://github.com/hrmrzizon/3DBasicExample) 의 _edu/skin_ 브랜치로 이동하면 미리 되어 있는것을 확인할 수 있다.

이전에 __Mesh__ 인스턴스를 활용해서 화면에 그릴려면 __MeshFilter__ 컴포넌트와 __MeshRenderer__ 컴포넌트가 필요했다. 그런데 이번에 필요한 컴포넌트는 조금 다르다. 그대로 __MeshFilter__ 와 __MeshRenderer__ 를 그린다면 리깅과 스키닝이 적용이 안된채로 그려진다. 물론 가만히 있는 용도로는 상관없겠지만 리깅과 스키닝이 적용된 결과를 보고싶으면 __SkinnedMeshRenderer__ 라는 컴포넌트를 사용해야한다. __MeshRenderer__ 처럼 다른 부수적인 컴포넌트는 필요없다. __SkinnedMeshRenderer__ 안에 모든 정보를 다 넣기 때문에 __SkinnedMeshRenderer__ 컴포넌트 하나만 있으면 된다.

_Rigging_ 작업은 _Mesh_ 복잡도와 뼈의 갯수에 따라 시간이 비례한다. 그래서 복잡한 모델을 작업할때는 _Rigging_ 하는데 시간이 꽤 많이든다. 하지만 우리는 간단한 마인크래프트 케릭터를 가지고 할 것이기 때문에 그다지 오래 걸리지 않을 것이다. __GameObject__ 를 적당한 좌표, 적당한 __Transform__ 간의 위치에 놓은 다음에 _SkinnedMeshRenderer.bones_ 배열에 등록해준다. 아래와 비슷하게 해주면된다. 아래 코드에서는 미리 배치가 되어있다는 가정하에 넣어놓았다.

```C#
SkinnedMeshRenderer skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();

skinnedMeshRenderer.bones = new Transform[] { transform.FindChild("bone0"), transform.FindChild("bone1"), transform.FindChild("bone2"),
                                              transform.FindChild("bone3"), transform.FindChild("bone4"), transform.FindChild("bone5") };

```

넣어준 _Bone_ 을 적용시키려면 특별한 행렬이 필요하다. 정점을 _Bone_ 과 연관시키려면 정점별 _Bone_ 과의 가중치와 앞에서 말한 행렬이 필요한데, 이 행렬이 단위행렬로(곱연산을 하면 값이 그대로 나오는 행렬이 설정되어 있으면 두가지 문제가 생긴다. _Bone_ 의 위치값을 정점에서 제외시키지 못해 이상한 거리에 _Skinning_ 이 되고, 루트 __GameObject__ 의 위치를 제외시키지 못해 한번 더 이상한 위치에 _Skinning_ 이 되어 버린다. 그래서 반드시 올바른 행렬값을 넣어주어야 한다. 기본 식은 아래와 같다.

```C#
Transform boneTransform = transform.FindChild("bone0");
GameObject rootObject = gameObject;

skinnedMeshRenderer.bindposes[0] = boneTransform.worldToLocalMatrix * rootObject.transform.localToWorldMatrix;
```

저 __SkinnedMeshRenderer__ 의 멤버 _bindposes_ 는 넣어준 _bones_ 배열의 갯수와 맞춰주어 넣어주어야 한다. _bone_ 별로 계산하는 행렬이니 말이다. 다음은 _skinning_ 이다. 우리가 만들 케릭터는 마인크래프트의 복셀 케릭터이니 상당히 간단하게 데이터를 설정할 것이지만 사실에 가까우면 가까울수록 필요한 가중치가 많아질 것이다. 정점별로 뼈의 기준에 따라서 얼만큼 가깝게 움직일 것이냐를 정해주어야 한다. Unity 는 이를 __BoneWeight__ 라는 구조체로 정의해 놓았다.

```C#
public struct BoneWeight
{
    public int boneIndex0 { get; set; }
    public int boneIndex1 { get; set; }
    public int boneIndex2 { get; set; }
    public int boneIndex3 { get; set; }
    public float weight0 { get; set; }
    public float weight1 { get; set; }
    public float weight2 { get; set; }
    public float weight3 { get; set; }

    ...
}
```

_boneIndex_ 들은 전부다 위의 _SkinnedMeshRenderer.bones_ 에 들어간 __Transform__ 의 인덱스들이다. 그리고 _weight_ 들은 해당 _bone_ 을 기준으로 얼마만큼 가까워질지에 대한 값이다. 가중치가 한 _bone_ 에 상대적으로 클수록 해당 _bone_ 의 위치에 더 가까워질 것이다. 하지만 우리는 여러 가중치를 설정할 필요없이 부위별로 한개의 가중치만 설정해주면 된다. 설정만 해주면 _skinning_ 은 끝난다. 생각보다 간단하다. 이 과정이 끝나면 직접 _bone_ 을 움직여 잘 따라가는지 확인할 수 있다.

```c#
int partCount = 6, vertexByPart = 24;
BoneWeight[] weights = new BoneWeight[partCount * vertexByPart];

for (int i = 0; i < partCount; i++)
{
    for (int j = 0; j < vertexByPart; j++)
    {
        weights[i * vertexByPart + j] = new BoneWeight() { boneIndex0 = i, weight0 = 1 };
    }
}

mesh.boneWeights = weights;
```

마인크래프트의 케릭터들은 한개의 _bone_ 을 기준으로 케릭터가 움직이기 때문에 _bone_ 을 정점별로 한개씩 설정해 주었다. 여기까지 설정해주면 설정된 _bone_ 들을 따라 그려진다. 여기까지 _bone_ 을 직접 설정해주고, _bone_ 별 변환 행렬을 설정해주고, 정점별로 가중치를 두어 해당 가중치로 _bone_ 을 따라가게 해주었다. 그런데 몇가지 짚고 넘어가야할 것들이 있다. __MeshRenderer__ 와 __SkinnedMeshRenderer__ 의 디테일한 동작의 차이다. 위에서 _skinning_ 이 적용되냐 마냐의 차이만 있다고 설명했다. 물론 기능상의 차이는 이것 뿐이지만 이 기능 때문에 벌어지는 몇가지 세부사항도 알아야 한다. Unity 시스템에서는 __MeshRenderer__ 가 그리는 정점들이 움직이지 않는다는 가정하에 모든 __MeshRenderer__ 를 모아서 최적화를 해준다. 물론 __Mesh__ 인스턴스가 가진 데이터가 적어야 한다는 한계가 있지만 복수의 오브젝트가 많아질 수록 이 부분은 꽤나 중요해진다. 하지만 __SkinnedMeshRenderer__ 는 크게 최적화가 되어있지 않아 많이 쓰면 쓸수록, __Mesh__ 인스턴스의 정점의 갯수가 많으면 많을수록 부하는 심해진다. 물론 한두개만 쓰면 크게 문제되는 상황은 없지만 많으면 많을수록 퍼포먼스가 떨어지는 디바이스에서는 문제가 된다. 즉 사용시 주의해서 사용해야 한다.

# 참조

- [Wikipedia : Skinning](https://en.wikipedia.org/wiki/Skinning)
- [Wikipedia : Skeletal animation](https://en.wikipedia.org/wiki/Skeletal_animation)
- [코드로 리깅하고 애니메이션 하기](https://github.com/GameEngineStudy/CodeRigging)
- [Unity ref: PlayerSettings.gpuSkinning](https://docs.unity3d.com/ScriptReference/PlayerSettings-gpuSkinning.html)
