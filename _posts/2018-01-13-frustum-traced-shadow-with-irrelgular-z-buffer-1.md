---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - fts
---

[frustum Traced Shadow with Irregular Z-Buffer 0]({{ site.baseurl }}{% post_url 2018-01-13-frustum-traced-shadow-with-irrelgular-z-buffer-0 %}) 에서 기법의 아이디어를 둘러봄으러써 대강 이 알고리즘이 무엇인지 살펴보았다. 이번 글에서는 논문에 수록된 포괄적인 전체 시스템과 복잡도에 대하여 알아볼 것이다.

<!-- more -->

### 전체 시스템

[이전 글]({{ site.baseurl }}{% post_url 2018-01-13-frustum-traced-shadow-with-irrelgular-z-buffer-0 %})에서 두가지 단계에 대해서 자세한 설명을 했었다. _Irregular Z-Buffer_ 를 생성하고 _Visibility Test_ 를 하는 것이였다. 실제 구현된 단계는 총 6개의 단계로 이루어진다고 한다.

첫번째로는 _Eye-Space Z-Prepass_ 를 해준다. 요즘의 엔진들이나 큰 규모가 아닌 게임이더라도 _Z-Prepass_[^L1] 는 거의 대부분 해준다. _Geometry Pass_ 가 두번 걸리기는 하지만 _Fill Rate_ 의 부하가 _Geometry Pass_ 의 부하보다 많이 커서 그런 듯하다. 중요한건 단순히 언급한 _Eye-Space Z-Prepass_ 를 뜻하는게 아니다. 이전에 언급한 _μQuad_ 의 빠른 계산을 위해 _G-Buffer_ 에 3개의 실수 값들을 넣는다. 이 3개의 실수는 실제 그려지는 카메라의 위치와 _Tangent Plane_ 의 4개의 코너중에 3개의 거리를 나타낸다. 이는 _μQuad_ 를 다시 계산하기에 충분하다고 한다.

이 방법은 _Visibility Test_ 의 속도를 빠르게 하는데 도움이 되지만, 당연히 _G-Buffer_ 의 공간이 부족한 경우에는 쓰지 못한다. AAA 급의 게임들은 _G-Buffer_ 를 bit 단위로 최대한 아껴쓰기 경우가 많기 때문에 이와 같은 상황이 일어날 수도 있다. 이런 경우에는 명시적으로 _Visibility Test_ 를 할때 _μQuad_ 를 계산한다고 한다. 아래 그림은 2009년에 발매된 _KillZone 2_ 의 _G-Buffer_ 사용을 나타내는 PT의 한 부분이다.

<br/>
![](/images/killzone2_g-buffer.png){: .center-image}
<center>출처 : <a href="https://www.slideshare.net/guerrillagames/deferred-rendering-in-killzone-2-9691589">Deferred Rendering in Killzone 2</a>
</center>
<br/>

두번째로는 씬의 경계를 설정해주는 것이다. _Shadow Mapping_ 에서 _Light-Space Projection_ 행렬은 씬에 딱 맞게 해주어야 한다.[^C1] 딱 맞지 않는 경우에는 _IZB_ 에 쓸모없는 텍셀을 생기게 하기 때문이다. 그래서 _Light-Space Projection_ 행렬을 계산하기 위해 _Compute Shader_ 와 _Z-Buffer_ 를 사용하여 _Bounding Box_ 를 계산한다. 이 계산은 화면의 해상도에 따라서 달라진다. 하지만 논문의 저자는 이 비용이 병목의 큰 원인이 아니기 때문에 특별한 해결 방법을 제시하지는 않는다.

세번째는 _Irregular Z-Buffer_ 를 만드는 것이다. 이전 글에서 _IZB_ 에 대한 대략적인 아이디어는 언급했었다. 더 디테일하게 이를 말해보면, 우선 _Eye-Space Z Buffer_ 를 참조해 _Light-Space_ 로 변환한 후에 _Light-Space A-Buffer_ 의 텍셀의 _Linked-List_ 에 넣는다.

_IZB_ 의 발상은 _Eye-Space_ 의 픽셀과 _Light-Space_ 의 텍셀이 1:1 로 매칭되지 않고 하나의 텍셀이 참조당하는 횟수가 1을 넘을때 _allasing_ 이 발생하는 것에서 시작되었다. 그래서 여기서 구현된 _IZB_ 는 텍셀에 _Linked-List_ 의 개념을 도입하여 보다 정확히 계산할 수 있게 하였다.

아래 그림은 _IZB_ 의 데이터를 나타낸다.

<br/>
![](/images/fts_depth_length_cull.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

왼쪽의 그림은 일반적인 _Shadow Map_ 을 나타내고, 중간의 그림은 _Linked-List_ 의 크기를 나타낸다. 흰색은 _Linked-List_ 의 크기가 0인 텍셀을 나타내고, 검은색에 가까워질수록 _Linked-List_ 의 크기가 점점 커지는 것을 나타낸다. 오른쪽의 그림은 필요없는 부분을 0으로 나타내고, 나머지 부분은 0 이상의 숫자를 나타내는 방식이다. 이는 아래에서 언급할 _Light-Space Culling Prepass_ 에서 쓰인다.

픽셀별로 여러개의 가시성(가려진 정도)를 나타내는 픽셀은 여러개의 _IZB Node_ 를 필요로 한다. 일반적인 _Shadow Map_ 과는 다르게 _μQuad_ 는 다른 _Light-Space Texel_ 에 _Projection_ 이 가능하다.

대충 생각해보면, _N_ 개의 픽셀별 쉐도우가 필요하면, _N_ 개의 _IZB Node_ 가 필요하다. 하지만 쓸데없는 데이터를(_Geometry_ 가 없는 경우) 넣지 않을 수 있으므로 _M_ 개의 _Light-Space Texel_ 에 _μQuad_ 를 투영한다면, 우리는 min(_N_, _M_)개의 _IZB Node_ 가 필요하다고 알 수 있다.

아래 그림은 _IZB_ 를 사용하는 디테일한 구조를 나타낸다.

<br/>
![](/images/fts_SimpleLayout.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

_IZB_ 의 데이터 구조는 _Light-Space A-Buffer_ : _Eye-Space A-Buffer_ 의 _Node_ 를 찾아가기 위한 데이터, _Eye-Space A-Buffer_ : 리스트의 크기를 나타내는 버퍼와 같다. 출력되는 결과 : _Visibility Buffer_ 또한 따로 존재한다. 이게 최종적으로 그려질때 사용된다.

다음은 _Light-Space Culling Prepass_ 다. _Visibility Test_ 를 위해 _Geometry_ 의 _Light-Space Conservative Rasterization_ 을 하게 되는데, GPU 에서 _Early-Z_ 기능을 제공한다면 쓸데없는 부분(아무것도 없는 텍셀, 가장 끝)을 컬링할 수 있다.

하지만 _Early-Z_ 하드웨어를 사용할때는 _Light-Space Z-Buffer_ 를 필요로 한다. 이는 조금 당황스러운 상황을 만든다. 그래서 이 단계에서는 반드시 스텐실 버퍼를 만들어야 한다. 위에서 언급한 쓸데없는 부분(아무것도 없는 텍셀, 가장 끝)의 _Depth_ 를 0으로 세팅한다. 나머지는 0 이상의 숫자로 세팅한다.

논문의 저자에 따르면, 엄청 큰 씬을 제외하고는 30% ~ 50% 의 성능 향상을 보였다고 한다. 이는 _Conservative Rasterization_ 으로 생성된 _Fragment_ 의 절대적인 숫자를 줄이고, 아무것도 없는 리스트를 스킵하면서 길이의 다양성을 없엔 효과다.

컬링을 된 이후에는 픽셀별로 _Visibility Test_ 를 해준다. 이때 각각의 폴리곤들은 임의의 텍셀 집합을 가리기 된다. 그리고 각각의 텍셀이 가진 리스트를 순회하면서 _Visibility Test_ 를 한다. 이때 _atomic OR_ 을 사용하여 _Visibility Buffer_ 에 기록한다. 여기서 가장 병목이 되는 구간은 각각의 폴리곤이 임의의 서로다른 길이를 가진 텍셀의 리스트를 커버링하여 각각의 쓰레드별로 실행되는 시간이 제각각이 된다. 문제는 시간이 제각각인 경우, 가장 느린 시간을 소모한 쓰레드를 기준으로 _divergence_ 하여 각각의 텍셀의 리스트의 길이 중 가장 긴 길이의 시간으로 맞춰진다. 이는 최악의 상황을 유발할 수 있다.

마지막으로 _Visibility Buffer_ 를 사용하여 실제 오브젝트들을 렌더링하면 된다.

### 복잡도 계산

위에서도 언급햇다시피 이 기법은 _N_ 번의 _Visibility Test_ 한다면, 시간 복잡도는 O(_N_) 과 같다. 여기서 _N_ 을 분해하면 다음과 같다. O(_La_ * _F_), _F_ 는 _Light-Space_ 의 _Fragment_ 갯수이고, _La_ 는 _Linked-List_ 의 평균 길이다.

_La_ 또한 다른 요소로 나타낼 수 있다. _Visibility Test_ 는 _Eye-Space_ 에서 한다. 그래서 _IZB Node_ 의 갯수는 _Eye-Space_ 의 해상도에 비례한다. 그리고 _Eye-Space_ 의 데이터는 전부 _Light-Space_ 에 기록되므로 _La_ ≈ (_Eye-Space Resolution_) / (_Light-Space Resolution_) 으로 계산될 수 있다.

하지만 위에서 언급했던 것과 같이 _SIMT_ 기반의 GPU 에서는 O(_La_ * _F_) 가 아닌 O(_Lm_ * _F_) 이 될 수 밖에 없다. _Lm_ 은 _Linked-List_ 의 최대 길이다. 결국 퍼포먼스를 내기 위해선 _Lm_ 의 길이를 줄이는 것이 가장 중요하다는 것이 된다.

이번 글에서는 전체 시스템과 복잡도에 대해서 알아보았다. 다음은 더 디테일한 구현 부분의 내용을과 _Alpha_ 처리에 대한 부분을 알아볼것이다.

## 참조
 - [Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows](http://cwyman.org/papers/tvcg16_ftizbExtended.pdf)

[^L1]: https://ypchoi.gitbooks.io/rendering-techniques/content/z_prepass.html

[^C1]: Cascaded Shadow Map 의 Crop Matrix 를 떠올리면 된다.
