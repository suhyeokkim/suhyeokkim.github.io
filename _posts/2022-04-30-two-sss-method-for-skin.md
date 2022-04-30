---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - subsurfacescattering
  - skin
---

graphics community 에선 피부를 표현하기 위해 많은 연구와 개발이 시도되었었다. 그 중에서도 사람의 피부는 어느 정도의 니즈가 있기에 많은 연구자/엔지니어들의 관심을 끌 수 밖에 없다. 여태 연구된 것들 중, 유명한 것 같은 두가지 : [_Efficient Rendering of Human Skin_](http://www.eugenedeon.com/wp-content/uploads/2014/04/efficientskin.pdf), [_Pre-Integrated Skin Shading_](https://advances.realtimerendering.com/s2011)을 간단하게 정리한다.

<!-- more -->

# subsurface scattering for skin

필자가 확인한 피부 렌더링을 하는 방법들은 전부 _subsurface scattering_ (이하 _sss_) 을 근사하는 방법이다. _sss_ 는 왜 자꾸 나오는가? 에 대한 질답을 선행해본다.

필자의 기준에서 _diffusion_/_specular_ 정의는 각각의 빛들이 표면에 부딫칠 때 특정 점에서 얼마만큼 반사되는지를 해당 점에 들어온 빛만 작용하는 것을 _specular_ 라고 표현하고, 그 이외의 모든 표면에서 들어온 빛들이 특정 점에서 작용하는 것을 _diffusion_ 이라고 표현한다.[^1] 여태까지는 빛의 작용을 근사하기 위해 이 둘을 나누어서 표현하고 적용했다. 문제는 _specular_ 는 한 점의 경우만 계산하면 어느 정도 현상을 모방할 수 있지만[^2], _diffusion_ 은 특수한 경우가 아니라면 특정 점 근처 표면의 경우까지 고려해야 현상을 모방할 수 있다. 아쉽게도 피부는 특수한 경우가 아니여서 널리 알려진 _lambertian reflectance_, _oren-nayar_ 같은 방법을 사용해도 꽤나 다른 결과를 낳는다.

<br/>
![reflection vs diffusion](/images/skin-0-reflection-vs-diffusion.jpg){: .center-image}
<center>출처 : <a href="https://favpng.com/png_view/scattered-light-light-diffuse-reflection-physically-based-rendering-specular-reflection-png/b7JsuG3g">Scattered Light - Light Diffuse Reflection Physically Based Rendering Specular Reflection PNG</a>
</center>
<br/>
<br/>

앞서 설명한 현상으로써의 _diffusion_ 은 _sss_ 와 같다. _specular_ 를 제외해버렸으니 표면 아래에서 산란되다가 표면 밖으로 빠져나오는 것만 남았고, 이게 _표면 하 산란_:_subsurface scattering_ 이 되었다.

이제 정의를 알아보았으니, 두가지 방법에 대해 알아본다.

# _Efficient Rendering of Human Skin_

_skin_/_sss_ 두가지 키워드에 대해서 알아보면 반드시 참고문헌에 들어가 있는 논문이다. _specular_ 관련 내용도 있지만, 이 글에선 _sss_ 만 다룬다. 그리고 이 방법은 표면 아래에서 빛이 튕겨 나오는 경우 중 딱 한번만 튕기는 경우를 고려하지 않는다. 대리석, 옥 등의 재질이 이런 경우를 고려하지 않으면 문제가 된다고 한다. 피부의 경우에는 고려하지 않아도 문제가 없다고 한다.

_diffusion profile_ 이란게 있다. 아래 그림에 나와 있는 것이 _profile_ 중 하나다. 이를 설명하자면, 이 사진은 일종의 단면이며 빛은 오로지 중간의 강한 빛 기둥이 밖에 없다. 그리고 이 하나의 빛 기둥이 주변으로 어떻게 튕겨져(확산되어=_diffusion_) 나가는지를 쉽게 볼 수 있게 한 것이 아래 사진이다. 아래 그림의 오른쪽 처럼 _R(r)_ 로 표현이 되는데, _r_ 은 중심점에서의 거리를 의미한다. 즉 해당 함수는 _raidal function_ 의 일종이다. 붉은색이 주를 차지하는 것처럼 보이는데, 아래 그래프에 산란되는 거리가 붉은색이 더 많은 것으로 나온다.

<br/>
![diffusion profiles](/images/skin-3-diffusion-profile.jpg){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/gpugems/gpugems3/part-iii-rendering/chapter-14-advanced-techniques-realistic-real-time-skin">GPU Gems 3 : Chapter 14. Advanced Techniques for Realistic Real-Time Skin Rendering</a>
</center>
<br/>
<br/>

위 그림의 _diffusion profile_ 의 RGB 그래프는 일종의 수치이므로, 이를 근사할 방법이 필요하다. 여기에서는 기저 함수를 _gaussian function_ 을 사용하고, 이의 유한한 합으로 나타낸다. 물론 이를 근사하기 위한 수치 최적화 방법도 언급되지만 이 글에선 자세한 방법은 다루지 않는다. 왜냐하면 피부 전용으로 제공하는 값이 있기 때문이다. 아래 그림에 표현되어 있다. 주목할 점은 albedo 텍스쳐가 언제나 존재하기 때문에, 각 채널의 가중치의 합이 언제나 1이여야 한다는 점이다. 방향은 따로 신경쓰지 않고, _irradiance_ 자체만 사용한다.


<br/>
![sog parameters](/images/skin-4-sog-parameters.jpg){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/gpugems/gpugems3/part-iii-rendering/chapter-14-advanced-techniques-realistic-real-time-skin">GPU Gems 3 : Chapter 14. Advanced Techniques for Realistic Real-Time Skin Rendering</a>
</center>
<br/>
<br/>

이제 각 재질별 정의된 _diffusion profile_ 을 기반으로, _texture space diffusion_, _translucent shadow mapping_ 두 아이디어를 수정/결합하여 피부의 _sss_ 를 표현한다. _수정된 TSD_ 는 각 재질별로 필요한 그 텍스쳐 공간=UV 공간에서 처리되는 _diffusion_ 방식이다. _수정된 TSM_ 은 depth/uv 를 함께 인코딩해서 두 정보로 표면의 두께를 계산하고, 이를 기반으로 광량을 조절한다. 먼저 _TSD_ 부터 알아보자.

## _수정된 texture space diffusion_

_수정된 texture space diffusion_ 은 다음과 같이 처리된다.

1. 원래 텍스쳐를 가지고 있는다.
2. (런타임/미리만듦) _uv-strech map_ 을 만든다.
3. 가우시안 커널을 가로/세로 나누어서 컨볼루션한다.
4. 만들어진 결과 텍스쳐를 가지고 있는다.
5. 원하는 숫자까지 반복한다.
6. _radial gaussian function_ 에 선형 결합해 오브젝트의 최종 _luminance texture_ 를 만든다.

_uv-strech map_ 이 필요한 이유는 _radial gaussian function_ 을 통해 컨볼루션 할 떄 평평한 텍스쳐 공간의 곡률과 굴곡진 월드 공간의 곡률의 차이로 왜곡이 일어나기 때문이다. 그래서 월드(or 모델) 좌표를 텍스쳐 공간 에 대해 차분한 값을 _uv-stretch_ 맵으로 저장한다. 그리고 컨볼루션시 이를 샘플링하여 왜곡을 없에준다.

<br/>
![tsd extended](/images/skin-5-tsd-extended.jpg){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/gpugems/gpugems3/part-iii-rendering/chapter-14-advanced-techniques-realistic-real-time-skin">GPU Gems 3 : Chapter 14. Advanced Techniques for Realistic Real-Time Skin Rendering</a>
</center>
<br/>
<br/>

_수정된 TSD_ 에 대해선 이외에도 BRDF/Texturing/seam 처리 등 자세한 사항들을 기술해놓았지만, 전부 기술하기엔 많아서 생략한다.

## _수정된 translucent shadow mapping_

_수정된 translucent shadow mapping_ 의 기본적인 아이디어는 _shadow mapping_ 의 방법에서 표면의 uv 좌표도 함께 저장하고, _light-space_ 에서의 _depth/normal_ 과 _texture-space_ 에서의 depth/normal 을 비교하여 두께(_thickness_) 를 계산한다. 계산된 두께는 컨볼루션된 각 텍스쳐에 저장된다. 방법은 아래와 같다.

1. _light-space_ 에서 물체의 _depth/uv_ 을 _shadow map_ 에 기록한다.
2. _texture-space_ 의 각 위치에서 _shadow map_ 의 _depth/uv_ 를 가져온다.
3. 각 위치의 _uv_ / 가져온 _uv_ 로 _normal map_ 을 샘플링하고, _ndotl_ 로 반대인지 아닌지를 판별한다.
4. 양수이면 같은 방향이므로 큰 _thickness_, 음수이면 정상 케이스로 판별한다.
5. 각종 _correction_ 을 거쳐서 _thickness_ 를 _irradiance texture_ 에 _alpha_ 에 저장한다.

이렇게 _convolution_ 된 각각의 텍스쳐를 저장하고, 실제 표면을 _shading_ 할때 참조해서 사용한다. 이 때 앞서 언급한 _uv-strech_ 와 _TSM map_ 를 샘플링해서 uv 공간 기준으로 스케일링을 해주어야 하고, _thickness_ 를 가져와서 표면을 얼마나 어둡게 할지 결정한다.

한계점은 분명히 많아 보인다. 개별로 수치 최적화를 써야해서 쉽게 에디팅 하기 어려울 것 같고, _directional light_ 이외의 광원은 어떻게 처리할 지 모르겠고, _convolution_ 데이터를 저장할 공간도 충분하지 않을 수도 있다. 또한 _pass_ 도 많은 편이라 _framebuffer switching_ 도 많아 보인다. 또한 저자가 언급한 것들도 있다. _uv seam_ 의 문제와 충분히 _physically based shading_ 않은 점도 언급된다. 하지만 여러모로 생각할 점이 많긴 한듯 하다.

# _Pre-Integrated Skin Shading_

[_Efficient Rendering of Human Skin_](http://www.eugenedeon.com/wp-content/uploads/2014/04/efficientskin.pdf)은 _convolution_ 을 이용해 계산하므로, 지금도 많은 기계에서 실현하기엔 어려움이 있다. 요즘엔 _texture space_ 가 아닌 _deffered rendering_ 기반에서 _screen space_ 로 계산한다곤 하지만, _fillrate_ 를 충분히 뽑아내지 못하는 QHD 같은 고해상도 혹은 모바일 gpu 가 대부분 따르는 타일링 아키텍쳐에선 여전히 거리가 먼 방법이다.

이러한 관점에선 _Pre-Integrated Skin Shading_ 은 그나마 가능성이 보이는 방법이다. _pre-integrated_ 되었기 때문에 _lut sampling_ 비용만 충분히 지불할 수 있다면 _forward_, _deffered_ 구조와 상관없이 사용할 수 있다.

_Pre-Integrated Skin Shading_ 발표 자료에선 피부가 특수하게 표현되는 세가지 경우를 찾아 말하고, 이를 해결할 방법을 제시한다. 세가지 경우는 아래와 같다.

1. surface curvature
2. small surface bump
3. color/soften shadows

발표 자료의 진행과 동일하게 하나씩 살펴본다.

## surface curvature

자주 사용하는 _wrap light_ 는 _ndotl_ 을 변경하는 방법 중 하나다. 하지만 앞에서 언급한 실제로 나타나는 _diffusion profile_ 에 제대로 맞춰지진 않는다. 그리고 표면의 곡률에 대해서도 신경쓰지 않는다. 그래서 미리 _diffusion profile_ 을 _curvature_/_ndotl_ 에 따른 lut 를 생성한다고 한다. _curvature_ (1/r) 는 모델 공간에서 버텍스에 저장했다고 한다.

<br/>
![pre diffusion-profile](/images/skin-6-diffusion-profile.JPG){: .center-image}
<center>출처 : <a href="https://advances.realtimerendering.com/s2011/">Siggraph 2011 Advances in Real-Time Rendering in Games, Pre-integerated Skin Shading</a>
</center>
<br/>
<br/>

<br/>
![baked ndotl](/images/skin-7-bake-ndotl.JPG){: .center-image}
<center>출처 : <a href="https://advances.realtimerendering.com/s2011/">Siggraph 2011 Advances in Real-Time Rendering in Games, Pre-integerated Skin Shading</a>
</center>
<br/>
<br/>

## small surface bump

_normal map_ 은 일반적으로 한번만 샘플링해서 사용한다. 하지만 피부의 경우 표면에서 곧바로 반사되지 않기 때문에, 단 한번의 샘플링으로만 사용하기엔 문제가 있다. 이 부분의 아이디어는 _pre-filtering_ 된 _normal map_ 을 사용하자는 것이다. 처음에는 4개의 _normal map_ 을 사용하자는게 나오지만(specular,r,g,b), 이는 텍스쳐가 기하급수적으로 늘어나는 문제가 있다. 그래서 저자가 제시한 최적화 방법은 두가지다. _vertex normal_ 만 사용하고, _normal map_(_specular 전용_) 을 주름/모공 같은 디테일을 표현하는데만 사용하거나 노말맵은 하나로 사용하되, 샘플러를 point 샘플러 / bilinear 샘플러 식으로 사용하는 것을 언급한다.

## color/soften shadows

_pcf_/_vsm_ 같은 끝을 부드럽게하는 방법에 기초한다. 이들은 전부 깊이를 _convolution_ 해서 끝부분만 부드럽게 만드는데 보통 빛의 감쇠값을 깊이로 구해서 색에 곱한다. 앞서 lut 로 만들어서 중간에 색값으로 치환한 방법처럼, 이 또한 _penumbra_ 의 정도를 _diffusion profile_ 을 사용해서 2d lut 에 매핑한다.

<br/>
![baked shadow](/images/skin-10-bake-shadow.JPG){: .center-image}
<center>출처 : <a href="https://advances.realtimerendering.com/s2011/">Siggraph 2011 Advances in Real-Time Rendering in Games, Pre-integerated Skin Shading</a>
</center>
<br/>
<br/>

# 결론

두가지 피부 표현을 위한 _sss_ 방법을 알아보았다. _Efficient Rendering of Human Skin_ 은 너무 많이 언급되어서 확인할 필요성을 느꼈었다. 내용이 풍부해서 처음 보기엔 너무 많긴 하다. 하지만 실용적인 방법만 있는게 아니라서 여러모로 처음 참고하기 좋았다. _Pre-Integrated Skin Shading_ 은 조금 더 실용적이라는 소리를 듣고 알아보았다. 모바일/VR 의 경우에는 확실히 _Pre-Integrated Skin Shading_ 를 사용할 수 있겠다는 생각이 들었다. 또한 _deferred rendering_ 기반에서도 _framebuffer_ 자원을 아껴야 한다면 고려해봄직 하다는 생각이 들었다.
 
## 참조

- [MJP Blog : An Introduction To Real-Time Subsurface Scattering](https://therealmjp.github.io/posts/sss-intro/)
- [Eugene d’Eon, David Luebke, and Eric Enderton : Efficient Rendering of Human Skin](http://www.eugenedeon.com/wp-content/uploads/2014/04/efficientskin.pdf)
- [GPU Gems 3 : Chapter 14. Advanced Techniques for Realistic Real-Time Skin Rendering](https://developer.nvidia.com/gpugems/gpugems3/part-iii-rendering/chapter-14-advanced-techniques-realistic-real-time-skin)
- [Sigraph 2011, Eric Penner : Pre-Integrated Skin Rendering](https://advances.realtimerendering.com/s2011/Penner%20-%20Pre-Integrated%20Skin%20Rendering%20(Siggraph%202011%20Advances%20in%20Real-Time%20Rendering%20Course).pptx)

## 각주

[^1]: 물론 diffuse 가 polarized 된 경우만 고려하는 경우도 있다. 이 글에선 _sss_ 에 관점을 맞추어 표현했다.
[^2]: incident light function 과 convolution 하기 위한 specular lobe 때문에 표현을 둘러서 했다.
