---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - hlsl
  - analysis
  - hbao+
---

__HBAO+ 3.1 버젼을 기준으로 글이 작성되었습니다.__

이전 [hbao plus anatomy 0]({{ site.baseurl }}{% post_url 2017-11-15-hbao-plus-anatomy-0 %}) 글에서 _HBAO+_ 을 알기위한 기본적인 개념들에 대해서 살펴보았다. 이번 글에서는 _HBAO+_ 의 구조와 메인 알고리즘은 _Horizon based ambient occlusion_ 을 제외한 나머지 것들을 알아볼 예정이다.

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

일반적인 모델을 렌더링 할때는 _Shader_ 에 입력으로 들어오는 정점의 기준 공간은 _Model-Space_(또는 _Local-Space_) _Position_ 이다. 그래서 _MVP_ 변환을 통해 _Rasterizer_ 가 처리할 수 있도록 _Clipping-Space_ 로 적어도 _Rasterizer_ 로 넘어가기 전에 변환해주어야 한다. 대강의 내용은 [Model, View, Projection 변환](https://docs.google.com/presentation/d/10VzsjfifKJlRTHDlBq7e8vNBTu4D5jOWUF87KYYGwlk/edit#slide=id.g25f88339be_0_0) 에서 확인할 수 있다.

## Deintereaved Texturing

## Processing Normal Data

## Bileteral Blur

# 참조 자료

 - [NVIDIA HBAO+](http://docs.nvidia.com/gameworks/content/gameworkslibrary/visualfx/hbao/index.html)
 - [Deintereaved Texturing](https://developer.nvidia.com/sites/default/files/akamai/gameworks/samples/DeinterleavedTexturing.pdf)
