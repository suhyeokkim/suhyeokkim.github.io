---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - vsm
---



[What is Shadow Mapping]({{ site.baseurl }}{ post_url 2017-11-30-what-is-shadow-mapping }) 에서 _Shadow Mapping_ 에 대한 간단한 번역 & 설명을 적어놓았다. 해당 글에서 _PCF_ 를 잠깐 언급했었다. 이 글에서는 _PCF_ 를 포함해서 _Shadow Map_ 을 필터링하는 방법에 대해서 알아보겠다.

첫번째는 _PCF_ 다. 풀어쓰면 _Percentage Closer Filtering_ 이라는 단어가 되며, _Shadow Map_ 을 여러번 샘플링해 _Percentage_ 를 소숫점으로 나타내서 _Shadow_ 가 생긴 정도를 나타내주는 _Filtering_ 기법이다. 쉽게 이해할 수 있도록 아래 그림을 보자.

<br/>
![](/images/PCF_Scheme.png){: .center-image}
<center>출처 : <a href="https://graphics.pixar.com/library/ShadowMaps/paper.pdf">Pixar : Rendering Antialiased Shadows with Depth Maps</a>
</center>
<br/>

위의 a) 는 아무것도 필터링 하지 않을 때의 _ShadowMap_ 샘플링하는 것을 보여주고, 아래 b) 는 _PCF_ 를 사용해 샘플링하는 것을 보여준다. 위 그림에서 _Surface at z = 49.8_ 은 그림자를 처리할 표면의 _Depth_ 또는 _Z_ 을 뜻한다. 그리고 _Light-Space_ 를 기준으로 해당 값보다 _Depth_ 값이 멀다고 판단될시에는 처리하지 않고, 가깝다고 판단될 때는 처리하는 걸로 해준다. _Shadow Map_ 에서 한 부분만 샘플링해서 하는 것이 윗 부분의 그림이고, 한 부분이 아닌 근처의 여러 부분을 샘플링해서 값을 구하는 것이 _PCF_ 다.

아래에 _PCF_ 를 사용하는 코드가 있다.

<br/>

``` HLSL
float PCF_FILTER( float2 tex, float fragDepth )
{
    //PreShader - This should all be optimized away by the compiler
    //====================================
    float fStartOffset = BoxFilterStart( fFilterWidth );
    float texOffset = 1.0f / fTextureWidth;
    //====================================

    fragDepth -= 0.0001f;
    tex -= fStartOffset * texOffset;

    float lit = 0.0f;
		for( int i = 0; i < fFilterWidth; ++i )
			for( int j = 0; j < fFilterWidth; ++j )
			{
				lit += texShadowMap.SampleCmpLevelZero(
                                FILT_PCF,
                                float2( tex.x + i * texOffset, tex.y + j * texOffset ),
                                fragDepth
                              );
			}
	return lit / ( fFilterWidth * fFilterWidth );
}
```

<center>출처 : <a href="http://developer.download.nvidia.com/SDK/10/direct3d/screenshots/samples/VarianceShadowMapping.html">NVidia : Variance Shadow Mapping Website</a>
</center>
<br/>

자세한 코드는 위의 출처에서 코드를 구해서 보면 될듯하다. _Texture2D::SampleCmpLevelZero_ 는 _MipMap_ 참조 레벨은 0으로 한채 텍스쳐의 값을 샘플링하여 주어진 인자와 비교하여 _Sampler_ 에 정해준 방식에 적합하면 1, 적합하지 않으면 0을 반환해준다.

해당 그림에서는 평균을 구하는 방법을 표기해놓았으나 다른 _NDF_ 를 써서 구현할 수도 있다.(_Gaussian Distribution_) 또한 규칙적으로 샘플링하는게 아닌 _jitter_ 를 사용해서 샘플링할 수도 있다고 한다. 일반적으로 _Poisson disk Distribution_ 을 사용한다고 한다.

_PCF_ 의 단순한 방법으로 _Shadow Map_ 을 _AntiAliasing_ 할 수 있다. 하지만 _Shadow Map_ 의 샘플링 횟수가 _PCF Kernel_(3x3, 5x5..) 이 커지면 커질수록 많아지기 때문에 꽤나 큰 _PCF Kernel_ 에서는 샘플링 부하가 걸릴 수 있다. 성능상 단점이 크나 _PCF_ 는 굉장히 많이 사용되는 기법 중에 하나라고 한다.

다음은 _Variance Shadow Map_ 이다. 이는 [_Chebyshev's Inequality_](https://en.wikipedia.org/wiki/Chebyshev%27s_inequality) 라는 통계학의 개념을 사용해 _Filtering_ 해준다. 먼저 _Shadow Map_ 을 저장할 때 _Depth_ 만 저장하는게 아닌 _Depth_ 의 제곱값 또한 같이 저장한다. _Filtering_ 에 쓰일 공식을 위해 같이 넣는다.

다음은 아래 코드와 같이 공식을 계산해준다.

<br/>

``` HLSL
float VSM_FILTER( float2 tex, float fragDepth )
{
    float lit = (float)0.0f;
    float2 moments = texShadowMap.Sample( FILT_LINEAR,    float3( tex, 0.0f ) );

    float E_x2 = moments.y;
    float Ex_2 = moments.x * moments.x;
    float variance = E_x2 - Ex_2;    
    float mD = (moments.x - fragDepth );
    float mD_2 = mD * mD;
    float p = variance / (variance + mD_2 );
    lit = max( p, fragDepth <= moments.x );

    return lit;
}
```

<center>출처 : <a href="http://developer.download.nvidia.com/SDK/10/direct3d/screenshots/samples/VarianceShadowMapping.html">NVidia : Variance Shadow Mapping Website</a>
</center>
<br/>

눈여겨 볼것은 샘플러를 _Linear_ 하게 설정해놓는 것이다.

하지만 _VSM_ 은 큰 단점이 하나 있다. 바로 _Light Leaking_ 이 일어나는 것이다. 이는 [GDC 2006 : Variance Shadow Map](https://http.download.nvidia.com/developer/presentations/2006/gdc/2006-GDC-Variance-Shadow-Maps.pdf) 에서 참조할 수 있다. 이를 해결 하는 근본적인 방법은 없다고 한다. 

두가지 기법의 차이는 텍스쳐 샘플링을 더 많이 하느냐, 메모리를 2배로 늘려주느냐의 차이에 있다. 속도를 따지면 _VSM_ 이 빠르다고 한다. 하지만 굳이 퍼포먼스를 낼 필요가 없다면 _PCF_ 를 사용하는 것도 나쁜 선택은 아닐것 같다. 선택에 대한 궁금증은 [OpenGL Forum : Shadow filtering: PCF better than VSM? ](https://www.opengl.org/discussion_boards/showthread.php/177219-Shadow-filtering-PCF-better-than-VSM) 글을 참조하길 바란다.

## 참조
 - [Pixar : Rendering Antialiased Shadows with Depth Maps](https://graphics.pixar.com/library/ShadowMaps/paper.pdf)
 - [MSDN : SampleCmpLevelZero](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509697.aspx)
 - [Variance Shadow Maps](http://www.punkuser.net/vsm/)
 - [GDC 2006 : Variance Shadow Maps](https://http.download.nvidia.com/developer/presentations/2006/gdc/2006-GDC-Variance-Shadow-Maps.pdf)
 - [Wikipedia : Chebyshev's inequality](https://en.wikipedia.org/wiki/Chebyshev%27s_inequality)
 - [GPU Gems : Shadow Map Antialiasing](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch11.html)
 - [NVidia : Variance Shadow Mapping Website](http://developer.download.nvidia.com/SDK/10/direct3d/screenshots/samples/VarianceShadowMapping.html)
 - [Github : TheRealMJP - Shadows](https://github.com/TheRealMJP/Shadows)
 - [OpenGL Forum : Shadow filtering: PCF better than VSM? ](https://www.opengl.org/discussion_boards/showthread.php/177219-Shadow-filtering-PCF-better-than-VSM)
