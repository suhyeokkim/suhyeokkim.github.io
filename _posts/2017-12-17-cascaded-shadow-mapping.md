---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - csm
---

[What is Shadow Mapping]({{ site.baseurl }}{% post_url 2017-11-30-what-is-shadow-mapping %}) 에서 _Shadow Mapping_ 에 대한 간단한 번역 & 설명을 적어놓았다. 이번 글에서는 _Shadow Mapping_ 을 효과적으로 사용하기 위한 _Cascaded Shadow Mapping_ 에 대하여 적어보겠다.

_Cascaded Shadow Mapping_ 을 구글 번역기에 돌려보면 _"계단식 그림자 매핑"_ 이라고 나온다. 조금 직관적이지 않은 말이지만 뜻 자체는 맞다. 간단하게 _Cascaded Shadow Mapping_ 에 대하여 말하자면 넓은 환경의 그림자를 위해 거리에(거의 _Depth_) 따라서 여러개의 _Shadow Map_ 을 생성하는 방법이다.

넓은 범위의 _Directional Light_ 가 닿는 그림자를 정확하게 표현하려면 꽤나 큰 크기의 _Shadow Map_ 을 사용해야 한다. 하지만 _Cascaded Shadow Mapping_ 을 사용한다면 여러개의 _Shadow Map_ 을 사용하여 보다 조금의 메모리를 사용하여 넓은 범위의 그림자를 표현할 수 있다.

## Shadow-map generation

_Cascaded Shadow Mapping_ 을 위한 _Shadow Map_ 생성은 앞서쓴 [글]({{ site.baseurl }}{% post_url 2017-11-30-what-is-shadow-mapping %})에서 설명한 방법과 거의 유사하다. 앞서 여러개의 _Shadow Map_ 을 생성하여 그림자를 표현한다고 언급했었다. 여러개의 _Shaodw Map_ 을 생성하는 기준은 _View frustum_ 을 _Depth_ 를 기준으로 여러개로 쪼개어 각 쪼개진 _frustum_ 을 기준으로 _Shadow Map_ 을 그린다.

_frustum_ 은 보통 _Depth_ 값을 정하거나 어떤 알고리즘을 사용하여 쪼갠다. 이는 다음 포스팅에서 언급할 예정이다. _frustum_ 을 쪼개주면 다음은 쪼개진 _Camera View frustum_ 의 각각의 8개의 꼭지점들을 _Light-Space_ 로 변환한다. 변환된 각각 꼭지점으로 2차원의 _aligned axis bounding box_ 의 위치를 구해준다. 가장 작은 X,Y 값과 가장 큰 X, Y 값을 구해주면 된다.

<br/>
![](/images/CSM_EffectOfCropMatrix.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/SDK/10.5/opengl/src/cascaded_shadow_maps/doc/cascaded_shadow_maps.pdf">NVidia : Cascaded Shadow Mapping</a>
</center>
<br/>

위 그림에서 XY 평면에서의 빨간색 선으로 되어있는 사각형이 언급한 _aligned axis bounding box_ 를 말한다. 이 _AABB_ 는 아래에서 특정한 행렬을 만들때 쓰인다.

[NVidia : Cascaded Shadow Maps  ](http://developer.download.nvidia.com/SDK/10.5/opengl/src/cascaded_shadow_maps/doc/cascaded_shadow_maps.pdf) 에서는 이 _Light-Space_ 로 변환하는 _MVP 변환_ 에서 _Projection_ 변환을 바꿔준다고 설명한다. 두개의 행렬이 나오는데, 하나는 직교 투영 행렬로(_orthogonal projection_) 나눠진 _frustum_ 의 _Far_ 값과 _Near_ 값을 통해 생성해준다. 그리고 나머지 하나는 _Crop Matrix_ 라는 변환 행렬이다.

위에서 구한 _Light-Space_ 의 _AABB_ 값을 통해 _Crop Matrix_ 를 계산한다. 아래 그림에서나오는 Mx, My 와 mx, my 는 각각 Maximum X,Y, Minimum X,Y 를 뜻한다.

<br/>
![](/images/CSM_CropMatrixCalc.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/SDK/10.5/opengl/src/cascaded_shadow_maps/doc/cascaded_shadow_maps.pdf">NVidia : Cascaded Shadow Mapping</a>
</center>
<br/>

이렇게 계산된 _Crop Matrix_ 의 역할은 해당 _AABB_ 로 _Shadow Map_ 이 그려질 범위를 결정해주는 역할을 한다. 다만 범위가 아주 정확하지는 않다. 아래 그림을 보자.

<br/>
![](/images/CSM_FarMiddleNear.png){: .center-image}
<center>출처 : <a href="http://ogldev.atspace.co.uk/www/tutorial49/tutorial49.html">OGLdev : Cascaded Shadow Mapping</a>
</center>
<br/>

위 그림과 같이 보통은 겹치는 부분이 생긴다. 사용시에는 _Depth_ 에 따라서 다르게 사용하기 때문에 크게 문제는 없다. 사용시에는 _Depth_ 값에 따라서 다른 텍스쳐를 가져오는 것과 텍스쳐를 샘플링할때 UV 값을 정점의 위치를 _Light-Space_ 로 변환해서 변환된 정점의 위치의 X,Y 좌표를 UV 값으로 사용하면 된다. 다만 각각의 _Shadow Map_ 마다 변환 행렬은 _Crop Matrix_ 때문에 다르기 때문에 따로 접근해야 한다.

자세한 사용법을 알고 싶으면 [NVidia : Cascaded Shadow Map Example](http://developer.download.nvidia.com/SDK/10/Samples/cascaded_shadow_maps.zip)에서 소스를 받아 보면 된다.

## 추가

_Cascaded Shadow Map_ 을 _1 pass_ 로 그리는 방법은 간단하다. 우선 _Shadow Map_ 들을 _TextureArray_ 를 통해 저장하고, _RenderTarget_ 을 _Geometry Shader_ 에서 각각의 렌더타겟별로 지오메트리를 추가해주어 각각의 _Pixel Shader_ 를 실행시키면 된다. 자세한 코드는 [여기](https://www.slideshare.net/dgtman/implements-cascaded-shadow-maps-with-using-texture-array)에서 볼 수 있다.

## 참조

 - [NVidia : Cascaded Shadow Maps  ](http://developer.download.nvidia.com/SDK/10.5/opengl/src/cascaded_shadow_maps/doc/cascaded_shadow_maps.pdf)
 - [MSDN : Cascaded Shadow Maps](https://msdn.microsoft.com/en-us/library/windows/desktop/ee416307.aspx)
 - [Github : TheRealMJP - Shadows](https://github.com/TheRealMJP/Shadows)
 - [OGLDev : Cascaded Shadow Mapping](http://ogldev.atspace.co.uk/www/tutorial49/tutorial49.html)
 - [Slideshare : implements Cascaded Shadow Maps with using TexturArray(한글)](https://www.slideshare.net/dgtman/implements-cascaded-shadow-maps-with-using-texture-array)
