---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - rendering
  - cg
  - try
---

이전에 쓴 글([handling uvs and material]({{ site.baseurl }}{% post_url 2017-05-15-handling-uv-and-material-in-unity %}))에서 쉐이더에 대한 언급을 한적이 있다. 간단하게 전체적인 의미와 역할에 대해서 설명했었다. 이 글에서는 조금 더 자세하게 알아보고 CG 를 이용해서 직접 다루는 방법에 대해서 알아보겠다.

3D 오브젝트는 GPU 에서 특정한 연산을 하여 화면상에 실제로 그려진다. 예전에는 그리는 방식이 정해져 있어 그 방식에 맞추어 데이터를 넣어주면 GPU 와 Graphics API 가 알아서 3D 오브젝트를 그렸었다. 하지만 기술은 점점 발전하여 프로그래머들이 직접 많은것을 제어할 수 있게 되었고 현재는 꽤 많은 것들이 가능하게 되었다. 그 발전속에서 나타난 것이 쉐이더다. 쉐이더는 3D 오브젝트를 그리는 방식을 적어놓은 코드라고 할 수 있다.

3D 오브젝트를 그리는 쉐이더 코드는 두가지로 나뉘는데, 하나는 vertex 를 처리하는 과정 또 하나는 pixel 자체를 처리하는 코드로 나뉜다. 이 두가지 과정을 잘 처리하면 게임에서 원하는 연출과 성능 두가지 토끼를 잡을 수 있다. 물론 잘하기 힘들다. 그래서 두 방법에서 프로그래머가 직접 코드를 짜서 넣으면서 게임의 그래픽을 원하는대로 커스터마이징이 가능하게 되었다. 이로써 꽤 많은 것을 실현 가능하게 되었었다. 하지만 이게 다가 아니였다.

쉐이더를 사용한 AAA급 3D 게임들과 함께 GPU 도 격렬하게 발전했다. 발전한 만큼 GPU 의 퍼포먼스는 점점 괴물이 되어가고 그 과정에서 vertex shader 와 pixel shader 를 단순하게 그리는 것에만 사용하는 것이 아니라 다른 계산이 필요한 곳에 써먹기 시작했고 편법을 사용한 많은 기술이 나왔었다. ([vtf](http://www.gamedevforever.com/61)) 그렇게 프로그래머의 니즈를 파악한 GPU 제조사는 다른 기술을 개발한다. 이름하여 GPGPU 라는 이름의 기술인데 풀어 쓰면 _"general purpose computing on graphics processing units"_ 이다. _GPU 상의 범용 계산_ 이라는 뜻이다. 즉 위에서 언급한 병렬 계산이 가능한 것들을 편법을 쓰지말고 직접 이 기술을 사용해서 사용하라는 것이다. 이 GPGPU 기술이 나오면서 GPU 의 하드웨어적인 퍼포먼스에 따라 엄청 많은 것들을 가능하게 되었다. GPGPU 를 통해 불편했던 편법을 사용하던 기법들이 변형되어 쏟아져 나왔으며 새로운 기술 또한 엄청나게 쏟아져 나왔다. 그리고 그 기술들은 일반적으로 알려진 3D 그래픽이 차용된 AAA 급 게임들에 사용되어 일반 사용자들은 엄청난 그래픽을 자랑하는 게임들을 경험할 수 있게 되었다. 또한 최근에 _AI_ 기술이 대두되면서 GPGPU 가 더욱더 각광받게 되었다.

이렇게 우리에게 다가오는 것은 꽤 많은 게임들의 발전인데, 다만 우리가 이 게임들의 기술에 접근하려면 꽤 많은 지식과 발상의 전환이 필요하다. 쉐이더만 하더라도 쉐이더 코드는 컴파일되어 GPU 에서 실행된다. CPU 에서 실행되는 일반적인 코드와 조금 다른 점은 CPU 에서 처리되는 것은 멀티스레딩을 하지 않는 이상 상당히 선형적인 코드를 짜게 되고 GPU 에서 돌아가는 쉐이더 코드를 짤 때는 병렬(parallel) 환경에서 돌아가게 짜야한다. 쉐이더 코드를 짤 때 첫번째로 겪게되는 어려움은 이것이다. 쉐이더까지 건드리게되면 경험이 어느정도 있는 상태일텐데, 개념을 조금 깨부수고 아예 병렬적으로 코드를 짜야하니 적응하는 것에 시간이 꽤나 소모된다.

Unity 에서 Shader 를 직접 만들어 사용하는 것에 대하여 알아보자.

<!-- more -->

Unity 는 여러 메인 스트림의 쉐이더 언어를 통해 쉐이더 코딩이 가능하다. 각각 언어마다 큰 차이는 없다. DirectX 와 OpenGL 에서 각각 지원하는 HLSL, GLSL 은 C 기반의 언어이고, Unity 에서 가장 많이 쓰이는 CG 는 NVidia 에서 MS 와 협력하여 만들어졌기 때문에 HLSL 과 비슷할 수 밖에 없다.([Cg & HLSL FAQ](https://web.archive.org/web/20120824051248/http://www.fusionindustries.com/default.asp?page=cg-hlsl-faq)) 또한 쓰이는 문법도 많은 편은 아니라 한가지를 익혀두면 나머지를 사용하는데 크게 불편함은 없을 것이다. 물론 Unity 에서 쓰이는 쉐이더는 ShaderLab 을 기반으로 코딩해야 하기 때문에 네이티브 CG, HLSL, GLSL 과 전체적인 개괄은 다르다. 더 궁금한 사람은 Unity 본사 엔지니어 Aras 가 답변한 [질문 링크](https://forum.unity3d.com/threads/hlsl-cg-shaderlab.4300/) 를 보면 된다.

Unity 의 기본적인 쉐이더 코딩은 ShaderLab 이라는 언어를 사용한다. 아래 ShaderLab 으로 되어있는 예제를 살펴보자.

```
Shader "Custom/TextureColor" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader {
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }

		Pass {
      Lighting Off

			constantColor[_Color]
			SetTexture[_MainTex] { combine texture * constant }
		}
	}

  FallBack "Diffuse"
}
```

위 예제는 색과 텍스쳐를 인자로 받아 텍스쳐에 색을 입혀서 출력해주는 간단한 예제다. 몇 줄 안되는 코드로 텍스쳐와 색을 입혔다. 언어 자체는 단순하고 간결하다. 다만 우리가 알아야하는 몇가지 문법이 있다. CG 나 HLSL 을 사용해도 결국 인라인, 삽입해서 사용하고 기본은 ShdaderLab 이기 때문에 전체를 감싸는 문법은 반드시 알아야 한다.

가장 첫 줄에 Shader 이름을 적어주면 Unity 에서 매터리얼의 쉐이더를 선택하는 부분에 적어준 이름이 나온다. 그리고 밑부분을 보면 Properties 라는 항목들이 있다. 이 부분은 실제로 매터리얼에 저장하는 정보들을 정의해주는 부분으로 지정된 자료형들만 세팅이 가능하다. 위 코드에는 색과 텍스쳐를 넣어줄 수 있게 해놓았다. 그 다음부터는 실제로 렌더링을 하는 부분에 대한 코드들이다. 다만 조금의 구조가 있어 기본적인 사항은 숙지해야 한다. 기본만 알면 쉽게 코딩이 가능하다.

SubShader 는 Shader 안에 여러개가 존재할 수 있는데 이는 꽤나 타당한 이유가 있다. 렌더링은 결국 빛과 여러 색들을 조합해서 화면에 뿌린다. 그리고 GPU 실제로 색을 그려준다. 그런데 낮은 버젼의 GPU 들은 꽤나 지원하지 않는 것들이 많다. GPU 별로 지원하는 Graphics API 버젼이 다른데 최신 기술을 쓰면 낮은 버젼의 Graphics API 를 지원하는 GPU 들은 해당 쉐이더 코드를 실행하지 못한다. 그래서 SubShader 의 개념을 두어 GPU 가 기능을 지원하지 못할 시 코드 상에서 아래 있는 걸로 한계단씩 내려가게 된다. 문제는 모든 SubShader 를 쓰지 못할때다. 그때는 Fallback 키워드에 적혀있는 쉐이더를 사용하여 그리게 한다. 위 예제 코드에서는 Diffuse 쉐이더를 사용하게 했다. 또한 Tag 를 설정해서 SubShader 를 Material 에서 설정할 수도 있다. Standard 쉐이더가 Tag 로 선택하는 기능을 지원한다.

SubShader 는 전체적인 그리는 방법을 포함하는 개념이고 그 다음 하부로 내려가면 Pass 라는 개념이 있다. 이는 진~~~짜로 렌더링을 하는 구문으로써 이 부분에 그리는 방법을 서술한다. CG 나 HLSL 을 넣어줄 수도 있다. 자세한 문법은 [링크](http://chulin28ho.tistory.com/159)를 참조하라.

특별하게 최적화를 할것이 아니라면 ShdaderLab 을 통해서 코딩을 해도 문제가 없다. 다만 좋은 퀄리티의 게임들은 대부분 쉐이더와 여러가지를 최적화를 시켜 주어야 하기 때문에 ShaderLab 만으로는 무리가 있다.

결국 모든 것을 제어하려면 CG 나 HLSL 을 사용해야한다. 그래서 우리는 CG 를 통해서 Unity 에서 쉐이더 코딩을 할 것이다. CG 는 두가지 종류로 쉐이더 코딩을 지원한다. 하나는 표면 쉐이더(surface shader) 를 통한 코딩이고, 하나는 정점 쉐이더(vertex shader) 와 픽셀 쉐이더(pixel shader) 의 조합으로 사용된다.

표면 쉐이더는 실제로는 없는 개념으로 쉐이더를 컴파일하면서 정점/픽셀 쉐이더로 변환되는 쉐이더 기능이다. 보통은 간단하고 빠르게 정점 라이팅을 코딩할 때 쓰인다. 기존에 존재하는 여러 라이팅 모델들을 지원하며 직접 정점 라이팅을 할 수도 있다. 다만 픽셀/프래그먼트 쉐이딩은 안된다. 그래서 상식적으로 생각하면 디퍼드 렌더링에서는 안되겠지만 디퍼드 렌더링에서도 가능하게 만들어 놓았다. 아래 표면 쉐이더의 예제를 보자. Unity 5.5.2f 버젼에서 기본으로 생성되는 쉐이더다.

```
Shader "Custom/NewSurfaceShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
pler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
```

ShdaderLab 에 비하면 코드가 상당히 길다. 새롭게 변수를 세팅해 주어야 하기도 하고 몇가지 세팅을 해주어야 하기 때문이기도 하다. 이 코드에서는 라이팅을 Unity Standard 의 PBR 라이팅 모델을 사용하고 있다. 아래 surf 코드에서 값을 계산하거나 참조
해서 반환해야 할 값을 넣어준다. 하지만 이 게시글에서 라이팅은 언급하지 않을 것이니 간단하게 보고만 넘어가자.

다음은 정점/픽셀 쉐이더를 조합한 쉐이더다. 아주 기본적인 쉐이더로써 대부분의 Graphics API 에서 지원하는 방식과 상이하다. 다만 표면 쉐이더에 비해서는 해줘야할 것들이 상당히 많다. 라이팅은 직접 메쉬에서 데이터를 가져와서 계산해야한다. 또한 작성해야할 쉐이더 코드자체도 두개이기 때문에 할 일이 꽤 많다. 아래의 예제는 색과 텍스쳐를 입히는 예제다.

```
Shader "Custom/ColorTextureCG" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 _Color;
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * _Color;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
```


<!-- Standard asset : blur -->

<!--
oo  쉐이더는 뭐시당가?
oo  vertex shader, fragment shader(pixel shader)
oo  GPGPU -> computeshader

oo  shaderlab? cg? hlsl?

xx  ShaderLab basic example

xx  CG 를 이용해서 쉐이더 직접 만져보기
xx   - 표면 쉐이더 : 기본 버텍스 라이팅(diffuse vs specular)
xx   - 버텍스 쉐이더 & 픽셀 쉐이더 : 색, 텍스쳐, 블러

xx  번외 : OnRenderTexture, rendertexture

예제 필요한 것
  Shaderlab 예제
  - Unity 사이트에 있는 것.
  CG 예제
  - sufrace
  - vert/frag
  - OnRenderTexture blur
-->

## 참조

 - [Fixed function pipeline](https://www.khronos.org/opengl/wiki/Fixed_Function_Pipeline)
 - [Unity ref : shader references](https://docs.unity3d.com/kr/current/Manual/SL-Reference.html)
 - [Unity forum : hlsl? cg? shaderlab?](https://forum.unity3d.com/threads/hlsl-cg-shaderlab.4300/)
 - [Unity forum : CG Toolkit is legacy](https://forum.unity3d.com/threads/cg-toolkit-legacy.238181/)
 - [NVidia developer : CG Toolkit](https://developer.nvidia.com/cg-toolkit)
 - [Unity tutorial : Shader tutorial](https://unity3d.com/kr/learn/tutorials/topics/graphics/gentle-introduction-shaders)
 - [Shaderlab Ref](http://chulin28ho.tistory.com/159)
 - [Optimize shader](http://shimans.tistory.com/41)
 - [세이더 기초](http://jinhomang.tistory.com/43)
