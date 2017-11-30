---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - hlsl

---

_Compute Shader_ 는 _DirectX 11_ 의 등장과 함께 본격적으로 쓰이기 시작했다. 지금은 _GPGPU_ 의 본격적인 기능으로 CPU 에서 처리하기 힘든 계산량을 책임지는 중요한 기능으로 자리잡았다. 실시간으로 현실적인 그래픽을 구현하기 위해 요즘의 게임들은 _Compute Shader_ 를 사용해서 여러 계산을 한다. 조금이라도 퍼포먼스가 필요하다면 당연히 쓰게되는 것이다.

사용하는 방법 자체는 간단하지만 _Compute Shader_ 를 사용해 어떤 기능을 구현하는지가 중요하다. 간단하게 사용방법부터 알아보자. Unity 에서는 _Compute Shader_ 를 위한 파일을 생성해야 한다.

![create computeshader](/images/create_computeshader.png){: .center-image}

프로젝트창에서 위 그림과 같이 생성해주면 된다. 그러면 아래와 같은 기본소스로 파일이 생성된다.

``` C
// Each #kernel tells which function to compile; you can have many kernels
#pragma kernel CSMain

// Create a RenderTexture with enableRandomWrite flag and set it
// with cs.SetTexture
RWTexture2D<float4> Result;

[numthreads(8,8,1)]
void CSMain (uint3 id : SV_DispatchThreadID)
{
	// TODO: insert actual code here!

	Result[id.xy] = float4(id.x & id.y, (id.x & 15)/15.0, (id.y & 15)/15.0, 0.0);
}
```

위의 소스는 _HLSL_ 로 코딩된 소스로 _DirectX 11_ 을 기준으로 코딩되어 있다. _UnityCG_ 파일안의 코드를 이용하면 _GLSL_ 로 자동 컨버팅이 되기도 한다. 직접 _GLSL_ 코드로 코딩하고 싶다면 _GLSLPROGRAM_ 과 _ENDGLSL_ 로 코드를 감싸주면 간단하게 해결된다.

내용은 간단하다. 각 텍셀별로 접근이 가능한 _Texture_ 를 이용해서(_DirectX_ 에서는 UAV 라고 칭한다.) _Texture_ 에 값을 채운다. _HLSL_ 의 자세한 문법과 사용방법은 [MSDN : SV_GroupIndex](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471569.aspx), [MSDN : Semantics ](https://msdn.microsoft.com/en-us/library/windows/desktop/bb509647.aspx) 들을 참고하길 바란다.

또한 쉐이더에서 뿐만아니라 _Unity_ 스크립트상에서도 데이터들을 연결해주어야 한다. 사용하는 유형은 간단하다. __UnityEngine.Texture__ 에서 파생된 텍스쳐들, __UnityEngine.RenderTexture__, __UnityEngine.ComputeBuffer__ 정도면 모든 활용이 가능하다. __UnityEngine.RenderTexture__ 에서는 _Cubemap_ 도 지원하니 간단하게 쓸 수 있다. 해당 인스턴스를 넘겨주는 방법은 아래와 같다.

``` C#
ComputeShader shader = ...;
RenderTexture rt = ...;

shader.SetTexture("Result", rt);
```

코드에서의 변수명을 맞추어 넣어주거나 해쉬값을 미리 가져와 넣어주면 된다. 다른 유형의 데이터들도 이런 방법으로 넣을 수 있다. 데이터를 넣어주면 다음은 _Compute Shader_ 를 실행하여 결과를 얻어야 한다. 간단하게 함수호출만 해주면 된다. 방법은 아래와 같다.

``` C#
ComputeShader shader = ...;
RenderTexture rt = ...;
int kernelIndex = shader.FindKernel("CSMain");

shader.Dispatch(kernelIndex, rt.width / 8, rt.height / 8, 1);
```

해당 _Compute Shader_ 소스는 텍스쳐안에 값을 채우는 코드이기 때문에 위와같이 해주었다. [Unity Reference : ComputeShader.Dispatch](https://docs.unity3d.com/ScriptReference/ComputeShader.Dispatch.html) 와 위의 _Compute Shader_ 소스를 참고하면 알겠지만 최대 3차원의 방식으로 _Compute Shader_ 의 그룹을 설정하여 계산이 가능하다.  _Compute Shader_ 소스의 _[numthreads(8,8,1)]_ 는 한 그룹의 _Thread_ 갯수를 나타내고, _ComputeShader.Dispatch_ 메소드는 몇개의 그룹을 실행시키는지 넘겨주는 메소드다. 아래 그림을 보면 조금더 쉽게 이해가 가능하다.

<br/>
![](https://msdn.microsoft.com/dynimg/IC520438.png){: .center-image}
<center>출처 : <a href="https://msdn.microsoft.com/en-us/library/windows/desktop/ff471569.aspx">MSDN</a>
</center>
<br/>

_Compute Shader_ 는 _DirectX 11_ 이상, _Vulkan_,  _OpenGL 4.3_ 이상, _OpenGL ES 3.0_ 이상, _Metal_ 에서 사용가능하다. 그 아래의 플랫폼은 지원하지 않는다. 또 유의해야 할점은 그래픽 드라이버별로 지원 기능이 조금씩 다를 수 있으니 기능을 유의하며 사용해야한다. [Unity Manual : ComptuteShader](https://docs.unity3d.com/Manual/ComputeShaders.html) 에서 조금 참고할 수 있다.

[Using Compute Buffer in Unity]({{ site.baseurl }}{ post_url 2017-08-01-using-compute-buffer-in-unity }) 에서 관련된 내용을 언급했으니 같이 보면 좋을듯 하다.

## 참조

 - [MSDN : SV_GroupIndex](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471569.aspx)
 - [MSDN : Semantics ](https://msdn.microsoft.com/en-us/library/windows/desktop/bb509647.aspx)
 - [Unity Manual : ComptuteShader](https://docs.unity3d.com/Manual/ComputeShaders.html)
