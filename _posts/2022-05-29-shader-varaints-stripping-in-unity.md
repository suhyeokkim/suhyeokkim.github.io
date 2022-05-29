---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
---

유니티에서 제공하는 _built-in shader_ 를 사용하면, Other/Rendering/ShaderLab (Unity 2018 기준) 의 메모리가 꽤 많이 늘어있는 것을 볼 수 있다. 여기에 _GraphicsSettings_ 에서 _strip_ 관련 세팅 조차 꺼놓았다면 엄청나게 크다. 이 글에선 이의 공간 복잡도를 줄일 방법을 이야기한다.

<!-- more -->

# shader variants?

_build-in shader_ 나 _universal render pipeline_ 에서(이하 _urp_) 사용하는 쉐이더는 우버 쉐이더로 제공된다. 우버 쉐이더란 많은 기능을 넣고 이를 사용자 기준으로 뺐다 꼈다를 할 수 있는 쉐이더를 말한다. Unity 에선 우버 쉐이더를 여러 프로그램을 컴파일해서 한꺼번에 들고 있다가, 사용할 때만 하나를 선택하는 방식을 택한다. 아래 _urp_ 의 일부를 발췌했다.

<!-- 
``` shaderlab
// hdrp - lit.shader
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma shader_feature EDITOR_VISUALIZATION
#pragma multi_compile _ DOTS_INSTANCING_ON
// enable dithering LOD crossfade
#pragma multi_compile _ LOD_FADE_CROSSFADE
```
-->

``` shaderlab
// -------------------------------------
// Universal Pipeline keywords
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _LIGHT_LAYERS
#pragma multi_compile_fragment _ _LIGHT_COOKIES
#pragma multi_compile _ _FORWARD_PLUS
#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

// -------------------------------------
// Unity defined keywords
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
#pragma multi_compile_fog
#pragma multi_compile_fragment _ DEBUG_DISPLAY

//--------------------------------------
// GPU Instancing
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma multi_compile _ DOTS_INSTANCING_ON
```

`#pragma multi_compile` 은 말 그대로, 여러개의 프로그램을 만들기 위해 사용하는 지시어다. 그 뒤에 오는 `_ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN` 들은, 각각의 전처리 심볼이 정의될 수 있는 것을 의미한다. `_` 의 경우는 아무 것도 없는 경우를 의미한다. 사용법이 비슷한 `#pragma shader_feature` 와 차이는 `#pragma multi_compile` 은 런타임에 변경되어야 해서 빌드파일/메모리에 적재되어야 하고, `#pragma shader_feature` 는 에디터에서 결정되고 빌드에는 하나만 들어간다는 차이가 있다.

그렇다면 메모리가 증가하는 `#pragma multi_compile` 을 왜 사용하는 것일까? 현 세대의 많은 gpu 들은 하나의 명렁어를 여러 코어에서 실행하기 때문에 분기가 갈라지면 모든 경우를 전부 실행해야 한다. 그리고 같은 분기를 타더라도 변경에 따른 암묵적인 성능 문제가 있기 때문에 차라리 여러 프로그램을 만들어서 스위칭 하는 전략을 위해 `#pragma multi_compile` 을 사용하는 것이다.

문제는 `#pragma multi_compile` 이 늘어날 수록 쉐이더 프로그램의(이하 _shader variants_) 갯수는 조합수로 늘어난다. 위의 _lit_ 의 픽셀 쉐이더의 총 조합수는 `#pragma multi_compile` 앞 키워드의 갯수를 전부 곱한 것 과 같다. 그래서 이러한 수많은 _shader variants_ 를 최대한 없에주어야 한다. 아래에서 디테일한 방법을 살펴보자.

<br/>
![reflection vs diffusion](/images/svs-1-variants-count.png){: .center-image}
<center>출처 : <a href="https://blog.unity.com/technology/stripping-scriptable-shader-variants">Unity Blog : Stripping scriptable shader variants</a>
</center>
<br/>
<br/>


# how to shader variants stripping?

없에는 방법을 알리기에 앞서, 제일 중요한건 최대한 `#pragma multi_compile` 사용을 늘리지 않는 것이다. 단순히 있는 것만 사용하면 문제가 없지만, 커스터마이징 한다면 반드시 알아야할 것이다. 나중에 없에는 작업을 하느니 처음부터 만들지 않는게 좋다.

첫번째로는 _GraphicsSettings_ 같은 각종 설정 파일에서 옵션을 설정하는 것이다. 다만 사용하지 않는 기능들을 직접 제외하는 것이기 때문에, 에디터에선 잘 사용되었지만 빌드 시에 옵션 때문에 예측되지 않은 작동이 나올 수 있다. _srp_ 설정과 상관 없이, _lightmap_ , _instancing_ 등 옵션의 사용 여부에 따라 제외 가능하다. 아래 그림이나 유니티에서 직접 볼 수 있다.

<br/>
![strip lightmap and instancing](/images/svs-2-strip-in-settings.png){: .center-image}
<br/>
<br/>

_urp_ 는 [링크](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/shader-stripping.html) 에서 관련 메뉴얼을 볼 수 있다.

두번째로는 쉐이더 작성시에 `#pragma skip_variants` 를 적절하게 사용하는 것이다. _built-in shader_ 를 커스터마이징 하는 경우 이를 유용하게 사용할 수 있다. 기존의 로직을 전부 변경하지 않고, 특정 쉐이더에서 특정 기능을 사용하지 않을 때 이를 직접 명시하여 _shader variants_ 를 줄일 수 있다. 아래 예시 처럼, 원하지 않는 variants 를 나열하기만 하면 된다.

``` shaderlab
#pragma skip_variants _SHADOWS_SOFT _SHADOWS_SCREEN _SCREEN_SPACE_OCCLUSION
```

세번째로는 `IPreprocessShaders` 를 상속받은 클래스를 만드는 것이다. 이는 아래와 같은 함수를 구현해야하는데, 단순히 키워드 조합에서 없엘 경우만 제거하면 된다.

``` csharp
public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> shaderCompilerData)
{
   var keywordDebug = "DEBUG";

   for (int i = 0; i < shaderCompilerData.Count; ++i)
   {
      // keywordDebug 중 하나를 가지고 있으면 빌드에서 제외한다.
      if (shaderCompilerData[i].shaderKeywordSet.IsEnabled(keywordDebug))
      {
            shaderCompilerData.RemoveAt(i);
            --i;
      }
   }
}
```

일반적으로는 예제 코드처럼 단순히 사용하지 않는 기능을 제외하는 방법을 사용하는게 제일 쉽다. 다만 키워드가 어떤 역할을 하는지 확인 후 사용을 해야한다. 이조차도 부족하다면 프로젝트 리소스에서 사용하지 않는 _shader variants_ 를 찾아내어 제거하는 것도 좋다. 특히 프로젝트의 리소스 자체가 적다면 맨 처음에는 많은 효과를 얻을 수 있다. 다만 빌드 후 결정되는 키워드를 정확히 알아야 실수를 방지할 수 있다.

_shader varaints_ 를 줄이는 세가지 방법을 살펴보았다. 결국 메모리 vs 성능 문제의 연장선상이기 때문에, `#pragma multi_compile` 을 적절히 사용하는게 중요할 듯

# 참조

- [URP : shader stripping](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@7.1/manual/shader-stripping.html)
- [Unity Blog : Stripping scriptable shader variants](https://blog.unity.com/technology/stripping-scriptable-shader-variants)
