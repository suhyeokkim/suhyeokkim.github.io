---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - rendering

---

__이 글은 Unity 5.6.1f 버젼에서 작성되었습니다. 다른 버젼에서는 에러가 날 수 있으니 참고 바랍니다.__

[Using Texture2DArray in Unity]({{ site.baseurl }}{% post_url 2017-06-04-using-texture2darray-in-unity %}) 에 이어 _DrawCall_ 을 줄이기 위한 방법에 대해서 소개하려한다. GPU Instancing 이라는 방법인데 _TextureArray_ 와 같이 응용해서 사용하면 획기적으로 _DrawCall_ 을 줄일 수 있다.   

일반적으로 알려진 _GPU Instancing_ 에 대해서 말하자면 컴퓨터의 RAM 에만 저장하던 데이터들을 GPU 메모리에 복사해놓고 GPGPU 나 쉐이더를 실행할 때 빠르게 데이터에 접근하는 것을 GPU Instancing 이라 한다. 만약 _GPU Instancing_ 을 사용하지 않으면 매번 _DrawCall_ 에 데이터를 넣어줘야하기 때문에 수많은 _DrawCall_ 이 걸리게 되고 이는 CPU 의 시간을 뺏어먹게 되어 영 좋지 않은 일이 된다. 보통은 같은 동작을 하는 오브젝트들을 최적화할 때 쓰인다. 사용하게 되면 _DrawCall_ 이 _O(__오브젝트 갯수__)_ 로 되던것이 O(1) 의 갯수로 줄어든다. 그래서 _TextureArray_ 와 같이 사용하게 되면 _DrawCall_ 이 _O(__오브젝트 갯수__ * __텍스쳐 갯수__)_ 로 계산되던게 _O(__1__)_ 로 바뀌어 버리니 CPU 시간을 엄청나게 많이벌 수 있다. 다만 GPU 메모리를 많이 잡아먹기 때문에 신경써서 데이터를 구성하지 않으면 무슨일이 일어날지 모른다.

<!-- more -->

기술을 써보기 전에 우선 구현 사항부터 생각해야 한다. 필자는 Unity 에서 지원하는 __SkinnedMeshRenderer__ 가 _DrawCall_ 배칭을 해주지 않아 간단한 스키닝을 직접 구현하였다. __SkinnedMeshRenderer__ 가 많은 기능을 지원하긴 하지만 __SkinnedMeshRenderer__ 컴포넌트의 갯수가 절대적으로 많아지고 매터리얼이 늘어나게 되면 어쩔 수 없이 원하는 기능을 붙여 직접 구현해야 한다. [InstancedSkinning](https://github.com/hrmrzizon/InstancedSkinningExmaple.git)에서 참고할 수 있다.

해야할 것은 두가지다. 쉐이더에서 데이터를 선언 후 직접 사용하는 코드를 짜주어야 하고, 스크립트에서는 필요한 데이터를 모아서 넣어주기만 하면 된다. 말로는 간단하지만 신경써주어야 할것이 많다. 필자 역시 간단하다고 생각하여 시작했으나 꽤 많은 삽질 끝에 성공했다.

_GPU Instancing_ 의 핵심은 GPU 메모리에 어떤 데이터들을 어떻게 옮겨놓고 그 데이터들을 어떻게 사용하느냐가 제일 핵심이다. 스크립트에서는 __MaterialPropertyBlock__ 인스턴스를 통해 데이터를 한꺼번에 세팅하고 _Graphics.DrawMeshInstanced_ 메소드를 호출해 그린다. 보통은 매 프레임별로 _Graphics.DrawMeshInstanced_ 호출하기 때문에 적당히 코딩이 되어있다면 필요할때마다 __MaterialPropertyBlock__ 인스턴스에 데이터를 갱신해주기만 하면 된다. __MaterialPropertyBlock__ 은 쉐이더에 들어가는 정보들을 취급하는 데이터 뭉치(chunk)다. __Material__ 은 쉐이더 정보와 필요한 데이터를 가지고 있는 인스턴스다. 쉐이더 정보를 가지고 있기 때문에 매터리얼의 갯수가 많으면 많을수록 _DrawCall_ 의 갯수가 늘어난다. 하지만 __MaterialPropertyBlock__ 은 __Material__ 과는 다르게 정보만 가지고 있는 것이기 때문에 _DrawCall_ 의 갯수가 늘어나지 않는다. __MaterialPropertyBlock__ 에 관한 자세한 사용법은 [Unity Reference : MaterialPropertyBlock](https://docs.unity3d.com/kr/current/ScriptReference/MaterialPropertyBlock.html) 을 참고하라.

아 그러면 쉐이더는 어디서 정의하냐고? _Graphics.DrawMeshInstanced_ 메소드는 __Material__ 과 __MaterialPropertyBlock__ 둘다 필요하다. 적당히 데이터를 분리해서 취급하면 된다. 아래 그리는 코드를 살펴보자. [InstancedSkinning - CharacterSet](https://github.com/hrmrzizon/InstancedSkinningExmaple/blob/master/Assets/2%20-%20InstancedSkinning/CharacterSet.cs) 에서 간추려서 가져왔다.

``` csharp
Dictionary<CharacterData, DrawData> drawDataDict;

void Update()
{
    var enumer = drawDataDict.GetEnumerator();

    while (enumer.MoveNext())
    {
        DrawData data = enumer.Current.Value;

        data.UpdateMatrix();
        data.UpdateMaterialblcok();

        Graphics.DrawMeshInstanced(
                data.mesh,
                0,
                material,
                data.mainMatrixList,
                data.block,
                castShadow ?
                    UnityEngine.Rendering.ShadowCastingMode.On :
                    UnityEngine.Rendering.ShadowCastingMode.Off,
                receiveShadow,
                drawLayerNumber,
                drawCamera
            );
    }
}
```

__Material__ 인스턴스는 단 한개이며 __Texture2DArray__ 를 사용해 모든 텍스쳐를 하나로 합쳐 _DrawCall_ 을 줄였다. __DrawData__ 는 _Graphics.DrawMeshInstanced_ 메소드 호출을하기 위한 구조체 데이터다. 기본적으로 물체를 그릴때 필요한 __Mesh__ 인스턴스와 각 그려야할 인스턴스 별로 필요한 변환행렬들을 가지고 있는 _DrawData.mainMatrixList_, 필요한 데이터를 저장하고 있는 __MaterialPropertyBlock__ 인스턴스 _DrawData.block_ 을 가지고 있다. _DrawData.UpdateMaterialblcok_ 메소드는 필요한 데이터들을 _DrawData.block_ 에 넘겨주는 메소드다.

여기까지 스크립트에서 해주어야할 것들에 대해 말했다. 필요한 데이터들을 준비하고 _Graphics.DrawMeshInstanced_ 로 한꺼번에 그려주는게 핵심이다. 이제 쉐이더 코딩에 대해 알아보자. Unity 에서의 쉐이더 코딩은 굉장히 복잡하다. Unity 는 여러 플랫폼을 위한 엔진이기 때문에 여러 플랫폼, Graphics API 에 대한 세팅이 필요하며 _GPU Instancing_ 을 사용할 때 약간의 애로사항이 있다.

_GPU Instancing_ 을 사용할 때 결국 데이터는 전부 배열로 들어오게 된다. 각종 쉐이더 언어(HLSL, GLSL)에서 지원하는 _instanceID_ 라는 배열에 접근하기 위한 인덱스가 있다. 이 인덱스에 접근하는 기능을 여러 플랫폼과 Graphics API 지원을 위해 해당 기능을 전처리기 구문으로 감싸놓았는데 Unity 엔진 사용자는 접근을 할수가 없다. 즉 배열의 인덱스에 직접 접근이 불가능하다는 것이다. 이렇게 되면 깔끔하게 코딩이 안되서 굉장히 불편할 뿐만 아니라 데이터도 효율적으로 쓰지 못한다.

또한 _Graphics.DrawMeshInstanced_ 를 사용하려면 옵션을 하나 붙여주어야 한다.

``` C
#pragma exclude_renderers d3d9 gles d3d11_9x
#pragma only_renderers d3d11 glcore gles3 metal vulkan

#pragma multi_compile_instancing

#include "UnityCG.cginc"
```

위와 같이 _UnityCG.cginc_ 파일을 포함하기 전에 전처리기 옵션 : _multi_compile_instancing_ 을 붙여주어야 한다. 저 옵션을 안붙이게 되면 컴포넌트 렌더러(__MeshRenderer__, __SkinnedMeshRenderer__)에서 개별로 쓰이는 쉐이더만 컴파일하게 되는데 그 상태에서 _Graphics.DrawMeshInstanced_ 를 사용하게 되면 아예 렌더링이 되지 않는다. 그래서 _GPU Instancing_ 에 필요한 쉐이더도 동시에 컴파일 하라는 옵션이 _multi_compile_instancing_ 옵션이다.

해당 옵션위에 다른 옵션들이 쓰여져 있는데 directX9 버젼이나 OpenGL ES 2.X 버젼에서는 제대로된 _GPU Instancing_ 을 사용하지 못하므로 _exclude_renderers_ 에 명시된 Graphics API 에서 돌아가는 쉐이더는 컴파일하지 말라는 옵션으로 생각하며 된다. 또한 동시에 _only_renderers_ 옵션도 사용했는데 이는 해당 Graphics API 를 위한 쉐이더만 컴파일하라는 옵션이다. 보통 두가지를 동시에 쓰지는 않지만 정확한 명시를 위해 적어놓았다. 이제 쉐이더 프로그램에서 인스턴싱된 버퍼들을 사용하는 방법과 편법에 대해서 알아보자.

``` C
struct a2v
{
	float3 uv : TEXCOORD0;
	float4 vertex : POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
};
```

여기서 주목할 것은 a2v 구조체에 있는 _UNITY_VERTEX_INPUT_INSTANCE_ID_ 매크로다. 이는 각 쉐이더 별로 _instanceID_ 를 정의해주는 매크로 인데, 역시나 여러 플랫폼을 위해 전처리기로 처리 되어있다. 그리고 a2v 는 버텍스 쉐이더에 들어가는 인자를 구조체로 묶어놓은 것인데 만약 프래그먼트 쉐이더에서 _GPU Instancing_ 을 하려면 인자로 들어가는 v2f 구조체에 _UNITY_VERTEX_INPUT_INSTANCE_ID_ 매크로의 정의가 필요할 것이다. 이 쉐이더는 필요가 없어 넣지 않은 상태이다. 이제 버퍼들을 정의하고 사용하는 방법에 대해서 알아보자.

``` C
#define UNITY_MAX_INSTANCE_COUNT 100

UNITY_INSTANCING_CBUFFER_START(_BonePositions)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition0);
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition1);
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition2);
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition3);
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition4);
	UNITY_DEFINE_INSTANCED_PROP(float4, _BonePosition5);
UNITY_INSTANCING_CBUFFER_END

float4 GetPosition(uint index)
{
	switch(index)
	{
		case 0:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition0);
		case 1:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition1);
		case 2:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition2);
		case 3:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition3);
		case 4:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition4);
		case 5:
			return UNITY_ACCESS_INSTANCED_PROP(_BonePosition5);
	}

	return float4(1, 1, 1, 1);
}

UNITY_INSTANCING_CBUFFER_START(_BoneMatrixs) /* 위 선언와 비슷함 */ UNITY_INSTANCING_CBUFFER_END

float4x4 GetMatrix(uint index) { /* 위 함수와 비슷함 */ }

v2f vert (a2v v)
{
	v2f o;

	UNITY_SETUP_INSTANCE_ID(v);

	uint boneIndex = v.uv[2];

	float4 pos = GetPosition(boneIndex);

	o.vertex = UnityObjectToClipPos(
					mul(
						GetMatrix(boneIndex),
						float4(v.vertex.xyz - pos.xyz,1)
					)
					+
					float4(pos.xyz, 0)
				);
	o.uv = v.uv.xy;

	return o;
}
<!-- __) -->
```

우선 데이터를 저장할 버퍼를 선언해야 한다. 이는 GPU 메모리에 저장되는 버퍼인데 DirectX 에서는 _constant buffer_ 라고 하고, OpenGL 에서는 _uniform buffer object_ 라고 한다. 하여튼 이렇게 선언되는 버퍼에 들어가는 정보는 __Material__ 이나 __MaterialPropertyBlock__ 에 저장한 정보들에서 똑같은 변수이름을 가진 변수에게 저장된다. 보통은 쉐이더의 _Properties_ 에 선언된 변수들은 __Material__ 에 저장하고, 버퍼 오브젝트들은 __MaterialPropertyBlock__ 에 저장된 데이터와 맞춰준다. 둘의 사용용도가 거의 일치하기 때문이라고 보면된다.

선언하는 방법은 간단하다. _UNITY_INSTANCING_CBUFFER_START_, _UNITY_INSTANCING_CBUFFER_END_ 로 정의할 영역을 정해주고 그 안에 필요한 데이터들을 _UNITY_DEFINE_INSTANCED_PROP_ 구문을 사용하여 정의해주면 된다. _UNITY_DEFINE_INSTANCED_PROP_ 구문에는 자료형과 이름을 써주면 알아서 정의가 된다. 이 역시 HLSL 과 GLSL 로 알아서 컨버팅 되도록 한것이다. 그리고 해당 변수에 접근할 때는 _UNITY_ACCESS_INSTANCED_PROP_ 를 사용하여 접근하면 된다.  이렇게 해주면 _multi_compile_instancing_ 때문에 일반적인 컴포넌트 렌더러에서 쓰는 쉐이더와 _Graphics.DrawMeshInstanced_ 에서 쓰는 쉐이더로 알아서 컴파일된다. _UNITY_ACCESS_INSTANCED_PROP_ 로 접근을 한 이유도 여기에 있다. _Graphics.DrawMeshInstanced_ 를 사용할때는 배열에 접근해야 하고, 컴포넌트 렌더러를 사용할때는 단순 인스턴스에 접근해야한다. 즉 배열의 인덱스로 접근하기위해 _UNITY_ACCESS_INSTANCED_PROP_ 를 사용한다고 보면된다.

근데 위 코드처럼 인스턴싱을 많이하게 되면 아래와 같은 에러를 띄우면서 컴파일이 안될때가 있다.

```
Can't continue validation - aborting. (on d3d11)
Index Dimension 2 out of range (12000 specified, max allowed is 4096) for operand #1 of opcode #5 (counts are 1-based). Aborting. (on d3d11)
```

그래서 위 코드에서 바꿔준 것이 맨 위에있는 전처리기 정의 구문이다.

``` C
#define UNITY_MAX_INSTANCE_COUNT 100
```

이는 약간 HACK 한 방식으로 커스터마이징을 한것이다. _Graphics.DrawMeshInstanced_ 에서 쓰이는 쉐이더는 배열로 변수들을 선언하는데 기본 배열의 길이가 500 이다. 물론 모바일 같은 플랫폼에서는 4를 나누어줘서 125 이긴 하지만 PC 대상으로 컴파일하면 정의한 변수 한개당 500개씩 정의가 되서 변환 행렬덕분에 엄청난 메모리를 먹게된다. 그리고 배열 아이템의 갯수 4096 개를 초과해서 에러가 나는 것이다. 그래서 전처리기로 처리한 것에 약간의 편법을 써서 _UNITY_MAX_INSTANCE_COUNT_ 를 필요할때마다 정의해주면 배열의 크기를 맘대로 조정할 수 있다. 위의 코드는 에러를 막기위해 임시적으로 조절한 것이지만 참조한 인스턴스의 갯수가 적으면 직접 조정해주는 편이 낫다. 물론 인덱스를 벗어나지 않는 범위에서 말이다. 이 방법은 Unity 사이트에서 built-in 쉐이더를 받아 확인하여 코딩하였다.

그리고 굳이 배열로 선언하고 싶지 않고 한번 실행하는 쉐이더당 한개의 변수만 필요한 경우 아래와 같이 단순하게 정의해주면 된다.

``` C
UNITY_INSTANCING_CBUFFER_START(_FragmentBuffer)
	float _TextureIndex;
UNITY_INSTANCING_CBUFFER_END

UNITY_DECLARE_TEX2DARRAY(_MainTexArray);

fixed4 frag (v2f i) : SV_Target
{
	fixed4 col = UNITY_SAMPLE_TEX2DARRAY(_MainTexArray, float3(i.uv, _TextureIndex));
	return col;
}

```
<!-- ___)(____) -->

저렇게 하면 단순하게 사용할 수 있다. 물론 컴파일 에러는 안난다. 해당 코드는 [Github : InstancedSkinningExmaple](https://github.com/hrmrzizon/InstancedSkinningExmaple) 에서 확인할 수 있다.

자세한 방법은 [Unity Manual : GPU Instancing](https://docs.unity3d.com/Manual/GPUInstancing.html) 에 적혀있으니 참고하길 바란다. 글을 쓰는 현재 2017년 6월 12일에는 한글 문서는 존재하지도 않는다. 영어로 읽어야한다.

## 참조

- [Unity Manual : GPU Instancing](https://docs.unity3d.com/Manual/GPUInstancing.html)
- [Slideshare : Approach Zero Driver Overhead](https://www.slideshare.net/CassEveritt/approaching-zero-driver-overhead)
- [Unity Reference : MaterialPropertyBlock](https://docs.unity3d.com/kr/current/ScriptReference/MaterialPropertyBlock.html)
