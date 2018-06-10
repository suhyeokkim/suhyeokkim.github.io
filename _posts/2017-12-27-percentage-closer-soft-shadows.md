---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - shader
  - shadow
  - rendering
  - pcss
---

[Shadow Map Filtering]({{ site.baseurl }}{% post_url 2017-12-19-shadow-map-filtering %}) 에서 _PCF_ 와 _VSM_ 에 대하여 간단히 알아보았다. 이번 글에서 설명할 것은 _PCF_ 를 활용한 _PCSS_ 다.

_PCSS_ 는 _Soft Shadow_ 를 구현하는 기법 중 하나로써 2005년에 발표되어 여태까지도 꽤나 알려진 기법이다. 우선 _Soft Shadow_ 가 무엇인지 알아보자.

<!-- more -->

<br/>

![](/images/soft_vs_hardshadow.png){: .center-image}
<center>출처 : <a href="http://www.assignmentpoint.com/science/computer/real-time-soft-shadow-rendering.html">assignmentpoint.com : Real Time Soft Shadow Rendering</a>
</center>
<br/>

위와 같이 빛을 가린 물체와 거리가 멀어지면 멀어질수록 밝아지는 그림자를 _Soft Shadow_ 라고 한다. 완전한 _Hard Shadow_ 는 어색하기 때문에 보통 _PCF_ 를 사용하여 끝부분을 부드럽게 처리했으나, 태양광 처럼 길게 그림자를 만드는 경우가 있으면 끝 부분이 가면 갈수록 부드러워져야 한다.

<br/>

![](/images/tree_shadow.jpg){: .center-image}
<center>출처 : <a href="https://www.youtube.com/watch?v=Ax8G8P3tA28">Youtube
</a>
</center>
<br/>


태양 빛에의해 만들어진 나무의 그림자다. 짧은 길이의 그림자는 적당히 _PCF_ 로 대략 표현이 가능하나 이런 길은 그림자를 고정된 사이즈의 _PCF_ 로 표현하기엔 무리가 있다. 그래서 나온것이 _PCSS_ 다.

_PCSS_ 를 보기전에, 우리가 알아야할 용어들이 있다. 바로 _Umbra_ 와 _Penumbra_ 다.

<br/>

![](/images/umbra_penumbra_antumbra.png){: .center-image}
<center>출처 : <a href="https://en.wikipedia.org/wiki/Umbra,_penumbra_and_antumbra">Wikipedia : Umbra, penumbra and antumbra </a>
</center>
<br/>

_Soft Shadow_ 가 표현하는 부드러운 부분의 그림자는 위 그림에서도 보이듯이 _Penumbra_ 라고 한다. _PCSS_ 에서는 부드러운 부분의 그림자를 _Penumbra_ 라고 한다. _PCSS_ 에서는 _Penumbra_ 의 크기를 사용하여 _PCF_ 의 샘플링 범위를 정해준다. 우선 _PCSS_ 의 _Penumbra_ 를 계산하는 방법을 보자.

<br/>

![](/images/PCSS_PenumbraSizeEstimation.png){: .center-image}
<center>출처 : <a href="https://http.download.nvidia.com/developer/presentations/2005/SIGGRAPH/Percentage_Closer_Soft_Shadows.pdf">Siggraph 2005 : Percentage-Closer Soft Shadows</a>
</center>
<br/>

맨위의 노란색으로 표시된 부분은 광원을 뜻하며, 일정한 범위로 빛을 비추는 _Area Light_ 로 가정한 후 계산한다. W - light 는 _Area Light_ 의 범위를 뜻한다. 중간에 있는 _Blocker_ 는 빛을 가리는 물체를 뜻하며, d blocker 는 가리는 물체와 빛과의 거리, d receiver 는 그림자가 비추는 물체와 광원 사이의 거리를 뜻한다. 그림자를 받는 부분과 빛을 가리는 물체와 광원을 서로 평행하다고 가정해서 계산한다. 2차원의 그림을 3차원으로 바꿔보자.

<br/>

![](/images/PCSS_Scheme.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/shaderlibrary/docs/shadow_PCSS.pdf">NVidia : Percentage-Closer Soft Shadows</a>
</center>
<br/>

보통 _Pixel Shader_ 에서 그림자의 비춘 정도를 계산하기 때문에 _Receiver_ 의 작은 부분을 기준으로 그림이 그려져 있다. 작은 부분을 기준으로 _Area Light_ 와의 _frustum_ 과 _Blocker_ 가 얼마나 충돌되는지 체크한다. 우리는 _Shadow Map_ 을 사용하기 때문에 아래 그림이 조금 더 실제 계산과 비슷하다.

<br/>

![](/images/PCSS_Scheme2.png){: .center-image}
<center>출처 : <a href="http://developer.download.nvidia.com/shaderlibrary/docs/shadow_PCSS.pdf">NVidia : Percentage-Closer Soft Shadows</a>
</center>
<br/>

그래서 _Shadow Map_ 의 빨간색으로 하이라이트 된 부분을 샘플링해 얼마나 가리고 있는지를 확인한다. 그러면 빛을 받는 정도를 알 수 있게 되는것이다. 해당 부분을 적당히 샘플링한 다음 평균을 구해서 _PCF_ 로 샘플링하는 범위를 계산한다. 계산하여 _PCF_ 에서 범위를 사용해 계산한다. 코드를 보면서 이해해보자.

<br/>

``` c
float PCSS_Shadow(float2 uv, float z, float2 dz_duv, float zEye)
{
	// ------------------------
	// STEP 1: blocker search
	// ------------------------
	float accumBlockerDepth = 0;
	float numBlockers = 0;
	float2 searchRegionRadiusUV = SearchRegionRadiusUV(zEye);
	FindBlocker(accumBlockerDepth, numBlockers, g_shadowMap, uv, z, dz_duv, searchRegionRadiusUV);

	// Early out if not in the penumbra
	if (numBlockers == 0)
		return 1.0;
	else if (numBlockers == BLOCKER_SEARCH_COUNT)
		return 0.0;

	// ------------------------
	// STEP 2: penumbra size
	// ------------------------
	float avgBlockerDepth = accumBlockerDepth / numBlockers;
	float avgBlockerDepthWorld = ZClipToZEye(avgBlockerDepth);
	float2 penumbraRadiusUV = PenumbraRadiusUV(zEye, avgBlockerDepthWorld);
	float2 filterRadiusUV = ProjectToLightUV(penumbraRadiusUV, zEye);

	// ------------------------
	// STEP 3: filtering
	// ------------------------
	return PCF_Filter(uv, z, dz_duv, filterRadiusUV);
}
```
<center>출처 : <a href="https://github.com/NVIDIAGameWorks/D3DSamples">Github NVIDIAGameWorks : D3DSamples</a>
</center>
<br/>

해당 픽셀이 어두워지는 정도를 반환하는 _PCSS_ 계산 함수다. 코드의 주석에서는 계산을 세단계로 나눈다. 첫번째로는 _Shadow Map_ 을 샘플링해서 얼마나 빛이 얼마나 가려지는지 계산한다. 이를 _STEP 1: blocker search_ 라고 표기해놓았고, 두번째는 _PCF_ 에서 샘플링할 범위를 결정하는 넓이를 계산한다. 이를 _STEP 2: penumbra size_ 라고 한다. 세번째로는 _PCF_ 를 계산해서 가려지는 정도를 반환한다. 자세한 코드는 출처에서 _SoftShadows_ 항목을 들어가면 볼 수 있다.

_PCSS_ 의 장점은 아무래도 확실한 _Soft Shadow_ 를 구현했다는 점이다. 비록 대략적으로 가정한 부분이 많지만 장면별로 잘 맞춰주기만 한다면 괜찮은 결과가 나올것 같다. 하지만 샘플링 횟수가 꽤나 된다. _PCF_ 만 하더라도 가볍지는 않은 편인데, _Blocker_ 를 계산하느라 더 많이 샘플링을 한다. 하지만 잘 만들어진 게임과 요즘의 GPU 에서는 아주 큰 오버헤드는 없는걸로 보인다. ([Redit : Nvidia HFTS (The Division)](https://www.reddit.com/r/nvidia/comments/49idz3/nvidia_hfts_the_division/))

## 참조
 - [Siggraph 2005 : Percentage-Closer Soft Shadows](https://http.download.nvidia.com/developer/presentations/2005/SIGGRAPH/Percentage_Closer_Soft_Shadows.pdf)
 - [NVidia : Percentage-Closer Soft Shadows](http://developer.download.nvidia.com/shaderlibrary/docs/shadow_PCSS.pdf)
 - [Github NVidiaGameWorks : D3DSample](https://github.com/NVIDIAGameWorks/D3DSamples)
