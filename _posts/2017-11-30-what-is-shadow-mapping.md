---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
---

※ 이 글은 [opengl-tutorial : shadow mapping](http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/) 게시물을 참고하여 쓰여졌습니다. 자세한 내용은 원문을 보는게 좋습니다.

_Shadow Mapping_ 실시간으로 그림자를 구현하기 위한 방법 중에 가장 널리 알려진 방법이다. 다른 방법들보다 구현하기 조금 쉬운편이긴 하나 이 방법은 완벽하지가 않기 때문에 방법 자체로는 완벽한 모습을 보이기 어렵고 다른 방법과 같이 사용하여 부족한 부분을 보완하여 사용해야 한다.

<!-- more -->

일반적으로 _Shadow Mapping_ 이라 말하면 아는 사람은 머릿속에 쉽게 떠오르는 방식이 있다. 빛의 반대쪽 방향에서 충분히 멀리 떨어져 한번 오브젝트를 그린다. 이때 _Pixel Shader_ 를 null 로 설정해서 _Depth Buffer_ 의 데이터만 가져온다. 또는 _Pixel Shader_ 의 출력을 _Depth_ 로 해도 된다. 그러면 보통 아래와 비슷한 2D 텍스쳐를 얻게 된다.

<br/>
![](/images/OGLTuto_DepthTexture.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

검은색에 가까워질수록(0에 가까워질수록) 해당 오브젝트의 위치가 가깝고, 흰색에 가까워질수록(1에 가까워질수록) 물체가 먼것이다. 오브젝트의 _Depth_ 를 렌더링할 때 정점에 사용되는 _MVP_ 변환 중 _View_ 변환은 임의의 위치와 빛의 방향을 계산하여 적용해준다. _Camera_ 를 기준으로 한게 아닌 _Light_ 의 방향을 기준으로 하여 관련된 것을 _Light-Space_ 라고 명명하는 경우도 더러 있다.

이제 생성된 _Shadow Map_ 을 사용하는 방법에 대해 알아보자.

<br/>
![](/images/OGLTuto_lightandshadow.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

위 그림에서 노란색으로 보이는 표면은 빛이 닿는 부분이고, 검은색으로 보이는 표면은 어떤 오브젝트에 의해 가려져 그림자가 드리운 표면이다. 해당 그림 위의 _Depth Buffer_ 를 응용하여 위처럼 가려지는 표면과 안가려지는 표면을 알아낼 수 있다.

_Depth Buffer_ 는 _Light-Space_ 를 기준으로 데이터를 저장하고 있다. 그리고 _Shader_ 에서는 _Local-Space_ 로 정점의 위치가 들어오기 때문에 _Depth_ 값을 비교하려면 두 값을 같은 공간으로 맞춰주어야 한다. [OpenGL Tutorial : Shadow Mapping](http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/) 에서는 _bias_ 행렬과 _Light-Space_ 가 적용된 행렬을 합성하여 입력으로 들어온 정점 데이터를 _Light-Space_ 기준으로 바꿔준다.

그 다음 정점의 _Depth_(_Z_) 값과 _Depth Buffer_ 에서 샘플링한 _Depth_(_Z_) 값을 비교하여 현재 정점의 _Depth_ 값이 더 크면(멀면) 그림자를 적용시킨다. 이러면 기본적인 _Shadwo Mapping_ 의 이론은 끝이다. 아래 간단한 _GLSL_ 코드가 있다.

``` C
vec4 ShadowCoord = DepthBiasMVP * vec4(vertexPosition_modelspace, 1);

float visibility = 1.0;

if (texture( shadowMap, ShadowCoord.xy ).z < ShadowCoord.z) {
    visibility = 0.5;
}
```

정점의 위치를 변환시키고, _Depth_ 값에 따라 _visibility_ 값을 변경시켜 그림자를 적용시킨다. 하지만 위에서도 언급했지만 _Shadow Mapping_ 자체에는 조금 문제가 있다고 언급했다. 해당 코드의 결과를 보자.

<br/>
![](/images/OGLTuto_1rstTry.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

위 그림은 굉장히 난장판이다. 세가지의 문제가 있는데 사진의 전체를 봐도 쉽게 알 수 있는 빛이 닿는 영역이 그림자 처리되는 것, _Shadow acne_ 가 생겼다고 말한다. 그리고 왼쪽아래 구석부분에 아주 조금 빛이 들어오는 것처럼 처리되는 것이 있다. 이는 _Peter Panning_ 이라고 부른다. 그리고 마지막으로 그림자와 빛이 닿는 부분의 경계가 울퉁불퉁한게 보일 것이다. 이를 계단현상, _aliasing_ 이라고 부르는데 흔히 게임에서 적용되는 _antialiasing_ 의 반대말이 맞다.

첫번째로 해결할 문제는 _Shadow acne_ 다. 이 문제는 아래 그림을 보면 쉽게 이해가 된다.

<br/>
![](/images/OGLTuto_shadow-acne.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

사선으로 나와있는 노란색 선들은 _Shadow Map_ 을 기준으로 _Light-Space_ 로 변환한 정점의 _Depth_ 값의 기준을 뜻한다. 그리고 표면 자체는 _Shadow Map_ 의 기준이 된다. 그림의 검은색 부분은 빛이 닿는 부분임에도 불구하고 그림자로 처리되는 부분인데, 이를 없에기 위해서는 값을 비교할때 단순하게 _bias_ 를 더해주면 된다.

``` C
float bias = 0.005;
float visibility = 1.0;

if (texture( shadowMap, ShadowCoord.xy ).z < ShadowCoord.z-bias) {
    visibility = 0.5;
}
```

이렇게 적용시키면 평면에서의 _acne_ 들은 제거가 가능하지만 곡면에서의 _acne_ 들이 제거가 안되기 때문에 _bias_ 를 조금 수정해준다.

``` C
float bias = 0.005*tan(acos(cosTheta)); // cosTheta is dot( n,l ), clamped between 0 and 1
bias = clamp(bias, 0,0.01);
```

이러면 _Shadow acne_ 들은 제거된다.

<br/>
![](/images/OGLTuto_VariableBias.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

다음은 _Peter Panning_ 을 언급할 차례다. [OpenGL Tutorial](http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/) 에서는 이 문제의 해결책으로 굉장히 단순한 방법을 제시한다. _Peter Panning_ 이 생기지 않도록 충분히 두꺼운 오브젝트를 배치하는 것이다.

<br/>
![](/images/OGLTuto_NoPeterPanning.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

이렇게 쉽게 해결된다.

마지막으로 다룰 문제는 _aliasing_ 이다. 이는 _Shadow Mapping_ 의 고질적인 문제로써 _anti-alisasing_ 기법을 통해 해결해왔다.

첫번째로 _Shadow Map_ 을 샘플링할 때 일반적인 색을 가져오는 샘플링이 아닌 다른 방식을 사용한다. _Shadow Map_ 을 한번 샘플링할 때 하드웨어에서 주변의 텍셀을 샘플링해 주변 텍셀과 비교를 수행해 모든 비교결과를 이중선형 보간을 적용한 결과를 주는 샘플링 방식을 사용한다고 한다. 만약 이중선형 보간을 사용하지 않는다면 _Point Sampling_ 을 여러번 하여 결과들을 사용해 _PCF_ 를 적용시켜주면 된다. 이렇게 해주면 조금 부드러운 결과가 나오게 된다.

하지만 이로써는 만족할만한 결과를 얻을 수 없어 주변을 여러번 샘플링해 값을 가져온다. 미리 생성된 _offset_ 을 사용해 기준 _UV_ 주변을 샘플링한다.

``` C
for (int i=0;i<4;i++){
  if ( texture( shadowMap, ShadowCoord.xy + poissonDisk[i]/700.0 ).z  <  ShadowCoord.z-bias ){
    visibility-=0.2;
  }
}
```

미리 생성된 _offset_ 은 _Poisson Disc_ 방식으로 생성된듯하다. _visibility_ 변수는 색의 어두움을 결정하는 변수로 한번 _Depth Test_ 에 걸리면 0.2를 줄여 0.2 ~ 1 사이의 값을 가진다.

이렇게 두가지 방식으로 _anti-aliasing_ 을 해주면 제법 그럴듯한 결과가 나온다.

<br/>
![](/images/OGLTuto_SoftShadows_Wide.png){: .center-image}
<center>출처 : <a href="http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/">opengl-tutorial</a>
</center>
<br/>

또한 _UV_ 좌표에 _offset_ 을 주는 방법은 꽤나 많다. 위의 방법은 랜덤으로 고정된 부분만 체크하지만 이 방법에 임의로 _offset_ 돌려주는 방법도 있다.

## 참조

 - [OpenGL Tutorial : Tutorial 16 Shadow mapping](http://www.opengl-tutorial.org/kr/intermediate-tutorials/tutorial-16-shadow-mapping/)
 - [OGLdev : Percentage Closer Filtering](http://ogldev.atspace.co.uk/www/tutorial42/tutorial42.html)
 - [GPU Gems : Chapter 11. Shadow Map Antialiasing](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch11.html)
 - [Wikipedia : SuperSampling\#poisson_disc](https://en.wikipedia.org/wiki/Supersampling#Poisson_disc)
