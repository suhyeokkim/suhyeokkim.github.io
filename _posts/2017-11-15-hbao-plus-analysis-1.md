---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - analysis
  - hbaoplus
  - linearize_depth
  - deintereaved_texturing
---

__HBAO+ 3.1 버젼을 기준으로 글이 작성되었습니다.__

이전 [hbao plus anatomy 0]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-anatomy-0 %}) 글에서 _HBAO+_ 을 알기위한 기본적인 개념들에 대해서 살펴보았다. 이번 글에서는 _HBAO+_ 의 구조와 _Linearize Depth_ 와 _Deinterleaved Texturing_ 에 대해서 알아보겠다.

## _HBAO+_ Pipeline

<br/>
![hbao+ with input normal](/images/hbao+_pipeline_with_input_normals.png){: .center-image}
<center>출처 : <a href="http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html">NVIDIA HBAO+</a>
</center>

<br/>
![hbao+ without input normal](/images/hbao+_pipeline_without_input_normals.png){: .center-image}
<center>출처 : <a href="http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html">NVIDIA HBAO+</a>
</center>
<br/>

그림이 두개가 있다. 하나는 _GBuffer_ 를 사용할 시 _World-Space Normal_ 버퍼와 _Depth Buffer_ 를 넘겨주어 계산하는 방식과 입력으로 _Depth Buffer_ 만 넘겨서 _Normal_ 데이터를 계산하는 두가지 방식에 대한 파이프라인이다. 두가지의 차이는 _Normal_ 데이터에 대한 처리방식만 다르다. 나머지 계산은 다를게 없다.

## Linearize Depths

코드를 보면 가장 처음에 시작하는 단계는 바로 _Linearize Depths_ 다. 이는 꽤나 알려진 방법이다. 하지만 필자는 _HBAO+_ 를 볼때 처음 봤기에 어느 정도의 설명을 해놓아야겠다. _Linearize Depths_ 를 알기 위해선 입력된 정점의 위치를 _Clipping-Space_ 로 변환하는 방법이 어떻게 이루어지는지 알고 있어야 한다.

일반적인 오브젝트를 렌더링 할때는 _Shader_ 에 입력으로 들어오는 정점의 기준 공간은 _Model-Space_(또는 _Local-Space_) _Position_ 이다. 그래서 _MVP_ 변환을 통해 _Rasterizer_ 가 처리할 수 있도록 _Clipping-Space_ 로 _Rasterizer_ 로 넘어가기 전에 변환해주어야 한다.(전체적인 내용은 [Model, View, Projection 변환](https://docs.google.com/presentation/d/10VzsjfifKJlRTHDlBq7e8vNBTu4D5jOWUF87KYYGwlk/edit#slide=id.g25f88339be_0_0) 에서 확인할 수 있다.
) 그래서 _Pixel Shader_ 로 넘어간 데이터들은 픽셀별로 들어가고, 픽셀별로 들어간 정점들의 위치는 _Clipping-Space_ 로 되어있다. 여기까지 이해했으면 아래 그림을 보자.

<br/>
![Frustom vs Clipping](/images/Graphics3D_ClipVolume.png){: .center-image}
<center>출처 : <a href="https://www.ntu.edu.sg/home/ehchua/programming/opengl/CG_BasicsTheory.html">3D Graphics with OpenGL Basic Theory</a>
</center>
<br/>

위 그림은 _View Frustom_ 과 _Clipping Volume_ 을 보여준다. _View Frustom_ 은 _Perspective_ 방식으로 카메라가 실제로 보여주는 공간을 시각화 한것이고, _Clipping Volume_ 은 _MVP_ 변환에서 _Projection_ 행렬을 사용할시 _View Frustom_ 에서 _Clipping Volume_ 으로 변환되는 볼륨을 시각화 한것이다. _Projection_ 변환은 아래와 같다.

<br/>
![perspective projection matrix](/images/projection_matrix.png){: .center-image}
<center>출처 : <a href="https://stackoverflow.com/questions/6652253/getting-the-true-z-value-from-the-depth-buffer
">Stackoverflow : Getting the true z value from the depth buffer</a>
</center>
<br/>

_Perspective Projection_ 은 _Frustom_ 기준 위치를 _Cube_ 기준 위치로 바꾸는 연산이기 때문에 실제 좌표의 왜곡이 발생한다. 우리는 Z(Detph) 값이 어떤식으로 왜곡되는지 알아야 한다. 우선 _Clipping-Space_ 로 변환할때, _Perspective_ 형식의 _View Frustom_ 의 _zNear_, _zFar_ 사이의 Z 값을 [0~1] 값으로 매핑한다. 그러면 _zNear_, _zFar_ 값을에 따라서 실제 좌표가 바뀐다. 그리고 값 자체가 실제 Z 값과 선형적으로 매핑되지 않는다. 아래 그림을 보자.

<br/>
![non linear depth](/images/nonlinearDepth.png){: .center-image}
<center>출처 : <a href="https://computergraphics.stackexchange.com/questions/5116/how-am-i-able-to-perform-perspective-projection-without-a-near-plane">Computer Graphics StackExchange : How am I able to perform perspective projection without a near plane?</a>
</center>
<br/>

그림이 조금 헷갈릴수도 있다. 세로축의 _d_ 값은 _Projection_ 을 한 Z, _Depth_ 값이고 가로축은 _World-Space_ 의 Z 값이다. 조금 헷갈릴수도 있는 부분은 세로축의 기준값이 윗부분이 0이고 아랫부분이 1이다. 이 부분은 신경써서 봐야한다. 이해했다면 변경된 _Depth_ 값은 실제 Z 값과 선형적인 관계가 아니고, 실제 Z 값으로 복원하려면 여러 연산을 해야하기에 _HBAO+_ 에서는 _Depth_ 값들을 _Linearize_ 하는 과정을 맨 처음에 넣은 것이다. 실제 Z 값으로 복원하는 이유는 간단하다. _Linear_ 하지 않은 _Depth_ 값을 연산시에 사용하면 보다 부정확한 결과가 나오기 때문이다. 특히 _SSAO_ 연산을 할때는 _Depth_ 값이 기본이 되기 때문에 해주어야 한다.

이 단계에서의 결론은 간단하다. _Clipping-Space_ 의 _Depth_ 값을 _View-Space_ 의 Z 값으로 변환하는 단계다. 처리하는 코드는 다른 단계에 비해 짧다. 만약에 넘겨준 _Depth_ 데이터들이 _View-Space_ 인 경우에는 옵션을 통해 처리할 수 있다.

## Deintereaved Texturing

위의 그림에는 _Generate HBAO+_ 라고 단순히 뭉뚱그려서 표현했지만 그 안에는 단순한 _Horizon based ambient occlusion(HBAO)_ 계산만 있지는 않다. _Deintereaved Texturing_ 이라는 테크닉과 함께 _HBAO_ 를 계산한다. _Computer Engineering_ 분야의 지식을 응용한 이론으로 개인적으로 이 이론을 접했을 떄 꽤나 충격이였다. 자세한 설명은 [GDC2013 : Particle Shadows & Cache-Efficient Post-Processing](https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf) 슬라이드의 몇장과 함께 보자.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_51](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_51.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

_Deintereaved Texturing_ 의 방법은 간단하다. 텍스쳐를 여러장으로 나누어 샘플링을 한 후 각각의 나눠진 텍스쳐를 샘플링한 결과를 하나로 합친다. 슬라이드에는 _Post-Processing_ 을 기준으로 설명이 되어있다. 이점은 생각하면서 보자.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_52](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_52.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

한 텍스쳐를 여러장으로 나누는건 _Multiple Render Target_ 을 사용해서 나눈다. 슬라이드는 4개를 기준으로 설명했지만 _DirectX10_ 부터는 최대 8개까지 지원하기 때문에 16개로 나누어 샘플링한다.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_53](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_53.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

다음은 나누어진 각각의 텍스쳐를 샘플링하여 원하는 알고리즘으로 결과를 낸다. 조각난 텍스쳐 한개당 한번 _DrawCall_ 을 걸어준다.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_54](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_54.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

_Deintereave_ 를 하기전까지는 넓은 범위의 텍스쳐를 샘플링하여 캐시 효율이 많이 떨어졌지만 텍스쳐를 나누어 각각 할때마다 처리를 하게되니 캐시 효율의 이득을 얻었다. 또한 각각의 _DrawCall_ 마다 텍스쳐의 용량이 조금만 필요하게 되니 대역폭의 이득도 얻게 된다.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_55](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_55.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

한번의 _DrawCall_ 로 나누어진 결과들을 합친다. _Deintereaved Texturing_ 은 여기서 끝이다. 실제로 _HBAO+_ 는 16개의 텍스쳐로 나누어 샘플링한다. _Multiple Render Target_ 이 8개까지 지원되어 16개로 _Deintereave_ 하려면 2번 _DrawCall_ 을 해야한다. 또한 샘플링은 16번 _DrawCall_ 을 하여 계산한다. 그래서 한번 _Deintereaved Texturing_ 을 사용하여 _Post-Processing_ 처리하려면 약 20번의 _DrawCall_ 을 계산해야 한다. 절대적으로 큰 숫자가 아니기 때문에 크게 신경쓸 필요는 없어보인다.

<br/>
![gdc2013_ParticleShadowsAndCacheEfficientPost_62](/images/gdc2013_ParticleShadowsAndCacheEfficientPost_62.png){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf">GDC2013 : Particle Shadows & Cache-Efficient Post-Processing</a>
</center>
<br/>

엄청난 성과를 거둔게 보인다. 캐시 히트 확률이 굉장히 올라갔고, 시간도 많이 절약했다. _HBAO+_ 의 성능향상을 시켜준 것이 이 _Deinterleaved Texturing_ 인듯하다.

## Reconstruction of Normal

_HBAO+_ 는 기본적으로 _Depth_ 와 _Normal_ 을 통해서 계산한다. 그렇기 때문에 외부에서 _Normal_ 데이터를 넣어주거나 직접 만들어야 한다. 보통 _Deffered Rendering_ 을 차용하는 시스템들은 간단하게 _GBuffer_ 의 _Normal_ 데이터만 넣어주면 된다. _Normal_ 데이터를 가져오는 코드가 있으니 조금만 수정하여 사용하면 된다.

_Normal_ 데이터가 없는 경우에는 라이브러리 내에 직접 계산한다. 계산하는 픽셀을 기준으로 상하,좌우별로 _Depth_ 와 화면상의 좌표계를 이용하여 _View-Space_ 의 위치를 구한다음 위치가 상하, 좌우별로 가까운 픽셀의 위치 오프셋을 사용해 외적하여 _Normal_ 값을 구한다.

# 참조 자료

 - [NVidia HBAO+](http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html)
 - [NVidia : Deintereaved Texturing](https://developer.nvidia.com/sites/default/files/akamai/gameworks/samples/DeinterleavedTexturing.pdf)
 - [GDC2013 : Particle Shadows & Cache-Efficient Post-Processing](https://developer.nvidia.com/sites/default/files/akamai/gamedev/docs/BAVOIL_ParticleShadowsAndCacheEfficientPost.pdf)
 - [GDCVault : Particle Shadows & Cache-Efficient Post-Processing Video](http://www.gdcvault.com/play/1017623/Advanced-Visual-Effects-with-DirectX)
