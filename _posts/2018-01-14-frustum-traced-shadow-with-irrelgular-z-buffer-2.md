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

[frustum Traced Shadow with Irregular Z-Buffer 1]({{ site.baseurl }}{% post_url 2018-01-13-frustum-traced-shadow-with-irrelgular-z-buffer-1 %}) 에서 포괄적인 전체 시스템과 복잡도에 대하여 알아보았다. 이번 글에서는 시스템 구현에 관한 디테일한 사항들을 알아볼 것이다.

첫번째로는 _Irregular Z-Buffer_ 와 _Sampling Rate_ 간의 최적화다. 논문의 저자는 기본적으로 _32spp_ (_sampling per pixel_) 를 제안했다. 정확히 짚자면, _Light-Space_ 에서 _Occluder Geometry_ 를 _Conservative Rasterization_ 을 하면 _Visibility Test_ 를 계산하는 것이, 한번 _Visibility Test_ 를 할때 32번을 하는게 가장 신경쓰이는 부분이다. 이의 결과를 저장하기 위해 두가지 방법이 있다고 한다. 하나는 _μQuad_ 를 _Light-Space_ 에서 _IZB_ 를 만들 떄 _Rasterize_ 하는 것, 다른 방법은 32 번의 _Visibility Test_ 샘플링 결과를 _IZB_ 에 저장하는 것이다. 전자는 비용이 크기 때문에 안쓰고, 후자를 선택했다고 한다. 이를 _Sample-based insertion_ 이라고 명명했다. 그래서 이 방식으로 _Prototype_ 을 만들어 보니, _IZB_ 의 중복을 위한 최적화를 했음에도 불구하고 한 픽셀당 8개 이상의 _IZB Node_ 가 생성되었다고 한다.

그래서 고안해낸 간단한 근사(_approximate_)하는 방법을 언급한다. _μQuad_ 의 _Normal_ 벡터와 _View Ray_(_Eye Direction_) 벡터의 내적 값이 0에 가까워질수록(90도에 가까워질수록) _μQuad_ 를 늘리는 것이다. 아래 그림의 왼쪽 그림을 보면 쉽게 이해할 수 있다.
그래서 고안해낸 간단한 근사(_approximate_)하는 방법을 언급한다. _μQuad_ 의 _Normal_ 벡터와 _View Ray_(_Eye Direction_) 벡터의 내적 값이 0에 가까워질수록(90도에 가까워질수록) _μQuad_ 를 늘리는 것이다. 아래 그림의 왼쪽 그림을 보면 쉽게 이해할 수 있다.

<br/>
![](/images/fts_microquad_elongate.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

보다 정확하게 계산 방법을 설명하자면, _μQuad_ 의 넓이는 표면의 방향과 상관없이 상수로 정해주고 _View Ray_ 의 앞뒤 방향으로 _μQuad_ 의 길이가 늘어나고, 그 방향을 따라서 1줄로 샘플링을 한다. 1차원이라고도 할 수 있겠다. 1 ~ 8 개의 샘플링을 해준다고한다. 위 그림의 오른쪽 그림을 보면 쉽게 이해할 수 있다.

다만 이는 단지 _Irregular Z-Buffer_ 를 _Approximate_(근사) 하는 것이기 때문에 오차가 생길 수 있다. _μQuad_ 가 커질수록 _IZB Node_ 를 넣는 것을 놓치고, _Light Leak_ 을 발생시킬 수 있다. 보통 가리는 물체가 작거나, 멀리있는 경우에 해당된다. _Light Leak_ 을 없에는 방법은 몇가지가 존재하는데, 가장 쉬운 방법은 _IZB_ 의 기본적인 모토인 1:1 샘플링을 맞춰주는 것이다. 하지만 이는 정확히 해주기에 어려운 경우가 있다고 한다. 그래서 다른 방법을 제시한다. _Conservative Rasterization_ 은 보통 결과에서 0.5 픽셀을 늘려준다. 하지만 1 픽셀 팽창(_dilation_)을 해주는 _Conservative Rasterization_ 을 사용하면 _Light Leak_ 을 막을 수 있다. 원래 _μQuad_ 2차원으로 샘플링을 했었으나 기준을 1차원으로 줄이면서 각각의 폴리곤의 넓이을 늘리는 방식으로 보완한 것이라고 생각하면 되겠다. 아래 그림에 적용을 한 사례가 있다.

<br/>
![](/images/fts_approx-insert_vs_over-conserv-raster.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

이전 글에서 언급한 복잡도는 O(_La_ * _F_) 이다. 우선 평균적인 리스트의 길이는 줄어든다고 한다. 샘플링을 하는 횟수가 최소 1/4 정도 줄었기 때문이다.(8 / 32) 그리고 더 넓은 _Conservative Rasterization_ 의 결과로 _Fragment_ 의 갯수는 최대 60% 증가했다고 한다. 이는 성능상 엄청난 이득을 가져온다.

하지만 이 방법은 _Approximate_ 하는 방법이란 것을 알아야 한다. 아주 극성맞은 경우와 안좋은 파라미터 설정에는 _Light Leak_ 이 발생할 수 있다고 한다. 아래 그림에서 그 경우를 볼 수 있다.

<br/>
![](/images/fts_lightleaks.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

왼쪽의 그림은 정상적으로 그림자가 보일 때, 두번째는 정말 안좋은 경우들이 겹친 _Light Leak_ 이 발생하는 경우, 세번째 경우는 세팅값을 맞춰주어 _Light Leak_ 을 없엔 장면이다. 하지만 결과를 잘 모르는 경우에는 이 결과들이 맞는지 아닌지 쉽게 구별할 수 있는 정도는 아니다. 즉 아주 정확한 결과를 원하는게 아니라면 그냥 써도 된다는 말이다.

두번째는 데이터 구조와 메모리 레이아웃 최적화다. 가장 맨처음 이를 구현할 때는 링크드 리스트의 2D 그리드의 형태로 만들었다고 한다. 각각의 리스트의 노드는 다음노드를 가리키는 포인터와 _G-Buffer_ 를 참조하기 위한 명시적인[^C2] 인덱스로 구성되었다고 한다. 하지만 이 구조는 _GPU_ 에서의 두가지 쓰레드 동기화를 필요로 했다. 하나는 _Global Node Pool_ 에서 비어있는 노드를 찾기위한 _Global_ 동기화[^C1], 나머지는 헤드 포인터(_Light-Space Data_)를 업데이트하기 위한 _Per-Texel_ 동기화[^C1]였다. 동기화를 많이 걸면 걸수록 성능상으로는 그다지 좋지않다. 그렇기 때문에 데이터 구조를 바꾸었다고 한다.

여러 시도 끝에 가장 성공적인 결과는 리스트의 각 노드의 크기를 줄이는 것이였다. 이를 위한 준비는 노드를 저장하기 위한 _Screen-Space Grid_ 버퍼를 미리 할당한다. 그리고 각 노드들은 자신을 기준으로한 다음 노드의 오프셋을 저장한다. 이는 _Linked-List_ 의 기준으로 보자면 _Next Pointer_ 가 된다. 이를 논문에서는 간접적인(_Implcit_) _G-Buffer_ 인덱스라고 부른다. 이렇게 계속 픽셀의 노드 정보를 참조하면서 픽셀의 위치를 _Linked-List_ 의 형태로 나타낼 수 있는 것이다. 아래 중간의 그림의 노란색 화살표는 이를 간단하게 나타냈다.

<br/>
![](/images/fts_SimpleLayout.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

이는 _IZB Node_ 의 크기도 반으로 줄이고, 위에서 언급한 두가지의 동기화 중 _Global_ 동기화를 안할 수 있게 되었다. 32spp 그림자를 보여주기 위해서는 적어도 픽셀별로 8개의 노드가 필요했다. 이렇게 반으로 노드의 크기를 줄임으로써 큰 퍼포먼스 향상을 얻게 되었다.

세번째는 헤드 포인터를 가지고 있는 _Light-Space Buffer_ 의 해상도다. 일반적인 _Shadow Mapping_ 기법의 _Shadow Map_ 의 해상도는 보여지는 정도를 결정하지만, 여기서의 해상도는 퍼포먼스를 결정한다.(_La_) 1920 x 1080 을 기준으로 추천하는 해상도는 1400 ~ 2500 사이라고 한다.

네번째로는 기존의 _Shadow Mapping_ 의 잘 알려진 기법인 _Cascaded Shadow Mapping_[^P1] 을 이 기법에 적용시키는 것이다. 이 기법의 원리는 _View frustum_ 을 원하는 갯수대로 쪼갠 후, 쪼개진 _frustum_ 안의 오브젝트들의 _Shadow_ 를 계산한다. 논문에서 쪼개는 방법은 _Sample Distribution Shadow Map_ 과 _Logarithm Partitioning_ 을 언급했다. 여기서는 쪼개진 _frustum_ 마다 전부 _IZB_ 를 생성한다. 이때 각각의 쪼개진 _frustum_ 의 끝부분이 잘 맞도록 신경써야줘야 한다고 언급했다. 논문의 저자는 구현할때 _2D Texture Array_ 를 사용하여 _IZB_ 를 저장하고, 병렬로 각각의 _Detph Texture_ 마다 _Light-Space Culling Prepass_ 를 넣어줬다고 한다. 일반적으로 각각의 _Cascade_ 를 계산할때는 한개당 하나의 _Pass_ 를 사용하여 계산하는데, 여기서는 1 Pass 로 적절히 프리미티브를 나누어 성능 향상을 고려했다고 한다.

_Cascade_ 의 적용은 _Occluder Geometry_ 의 _Rasterize_ 퍼포먼스를 안고 가면서 _Thread Divergence_ 의 시간을 줄여준다. 이는 사용시 적절한 타협점을 찾아야 한다는 뜻으로, 보통은 두개의 _Cascade_ 를 사용하고, 복잡한 게임에서는 3개나 4개의 _Cascade_ 를 사용하여 상황에 따라 뜀뛰는 시간을 최소화 시킨다. 아래 그림은 _Cascade_ 의 효과를 증명해준다.

<br/>
![](/images/fts_cascaded-izb.png){: .center-image}
<center>출처 : <a href="http://cwyman.org/papers/tvcg16_ftizbExtended.pdf">Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows</a>
</center>
<br/>

다섯번째로는 _N dot L Culling_ 이다. 일반적으로 _N dot L_ 의 값이 음수가 되는 경우에는 0으로 클램핑하여 사용한다. 이 말은 값이 음수나 0 인 경우에는 무조건 _Shadow_ 가 비춘다는 말이다. 이때는 _La_ : 평균적인 _IZB_ 리스트의 길이를 줄여 성능 향상을 해줄 수 있다고 한다. 보통은 10 ~ 15% 의 성능향상을 해준다고 한다.

여섯번째로는 _Early-Z_ 의 개념을 응용한 _Early-Out_ 이다. _Visibility Test_ 에서 한 픽셀을 완전하게 그림자를 드리우는 경우, 다음 후속으로 같은 픽셀에 _Node_ 가 추가될 필요가 없다. 그러므로 완전히 그림자 처리가 되는 부분은 _Node_ 를 지워준다. 이때 _atomic_ 연산을 사용하지 않는데, 최악에 경우에는 _Visibility Test_ 를 다시할 수도 있다. _Early-Out_ 은 추가적인 시간과 메모리를 요구함에도 불구하고 10 ~ 15% 의 성능향상을 보인다.

일곱번째로는 _Unchanged Mask_ 를 이용한 메모리 동기화다. _Visibility Test_ 는 메모리 대역폭, 처리량, 동기화로 인하여 병목이 일어난다. 픽셀 각각의 _Visibility Mask_ 를 사용해 동기화를 한다. 정확히 말하면 각각의 폴리곤들이 픽셀의 가시성을 테스트 할때 _Race Condition_ 을 피하기 위하여 동기화를 하여 _Visibility_ 를 기록한다. 그러므로 _Visibility Mask_ 는 반드시 폴리곤이 기존의 _Visibility_ 를 바꿀 때만 업데이트된다. 바뀌는지 비교를 하기위해 이전에 사용한 마스크를 써야하지만, 이는 최고 14% 의 성능 향상을 보여준다고 한다.

마지막으로는 코드를 통한 _Latency Hiding_ 이다. 단계가 복잡하여 _Memory Latency_ 가 꽤나 긴편인데, GPU 에서는 이 _Latency_ 를 감출 방법이 없다. 다행히 사전에 루프를 돌면서 _G-Buffer_ 좌표를 계산하여 _Latency Hiding_ 이 가능하다고 한다. 이는 5 ~ 15% 성능 향상을 보였다고 한다.

시스템 구현에 대한 디테일한 사항은 여기까지가 끝이다.

마지막으로 _Transparency Geometry_ 를 처리하는 방법에 대해서 써보겠다. 이 기법의 _per-pixel_ 테스트는 _Visibility Mask Buffer_ 에 결과가 저장된다. _Visibility Mask Buffer_ 의 효율적인 사용을 위해 항상 각 픽셀의 여러개의 32bit 데이터를 저장해준다고 한다. 이정도의 크기라면 단지 _Visibility_ 만을 사용하는게 아니라 _Opacity_ 또한 저장이 가능하다. 통상적인 가시성을 위한 투명 오브젝트의 처리 방법은 _Alpha to Coverage_[^C3] 를 쓴다고 한다. 그리고 여기에서도 비슷한 방법을 사용할 수 있다고한다.

처음에는 _Coverage_ 를 계산하기 위해 _Visibility Test_ 를 해준다. 그리고 해당 알파가 저장된 텍스쳐를 참조하여 투명도를 가져오고, 해당 투명도를 사용하여 _Alpha to Coverage_ 를 실행하여 투명도 마스크를 얻는다. 이를 비트 AND 연산으로 합쳐서 _Coverage_ 를 _Visibility Buffer_ 에 저장한다.

이 기법에서 알파 데이터를 처리하는 방법은 두가지로 나뉜다. 적은 비용으로 _Aliasing_ 을 생기게 하는 방법과 높은 비용으로 완벽하게 구현하는 방법으로 나뉜다. 적은 비용의 방식은 _Alpha_ 텍스쳐의 값을 _IZB Node_ 를 순회하기 전에 가져와서 계산하는 방식이다. _Light-Space Texel_ 을 기준으로 계산하므로 _Aliasing_ 이 생길 것으롸 예상된다. 하지만 이 논문의 저자는 구현물을 이 방식으로 구현했다고 한다. 나머지 한개의 방식은 _IZB Node_ 를 하나하나 순회하면서 _Alpha_ 텍스쳐의 값을 가져와 계산하는 것이다. 이는 일반적으로 생각되는 텍스쳐 샘플링의 부하와 _Varing_ 부하를 생기게 한다. 이는 꽤나 큰 비용이라고 한다.

여기까지가 끝이다. 논문에 그 다음 내용들은 전부 퍼포먼스들의 분석밖에 없다. 다음으로 쓸 내용은 _HFTS_ 에 대한 내용이다.

## 참조
 - [Frustum-Traced Irregular Z-Buffers: Fast, Sub-pixel Accurate Hard Shadows](http://cwyman.org/papers/tvcg16_ftizbExtended.pdf)
 - [Intel Developer Zone : Sample Distribution Shadow Maps](https://software.intel.com/en-us/articles/sample-distribution-shadow-maps)

[^C1]: 여기서의 동기화는 _atomic_ 의 개념을 말한다. 성능상의 단점은 다른 쓰레드에서 선점하는 경우에는 기다리는 것이다.

[^C2]: 명시적이란 뜻은 바로 넣어서 계산할 수 있는 절대적인 위치의 텍셀 인덱스를 뜻한다.

[^C3]: [https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f](https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f)

[^P1]: 이 블로그에서 _Cascaded Shadow Mapping_ 에 대한 내용을 다루었었다. [여기]({{ site.baseurl }}{% post_url 2017-12-17-cascaded-shadow-mapping %})에서 볼 수 있다.
