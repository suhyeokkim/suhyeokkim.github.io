---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - hdr
  - displaymapping
---

※ 이 글에서는 _HDR_ 시스템을 이해하기에 필요한 _colorimetry_ 의 부분적인 내용을 숙지하고 있는 것을 가정하고 설명합니다. 만약 그렇지 않다면 "[what is color spaces and gamuts]({{ site.baseurl }}{% post_url 2019-07-11-what-is-color-spaces-and-gamuts %})" 를 읽는 것을 추천드립니다.

컴퓨터를 사용하는 모든 사람들이 많이 바라보는 것은 모니터다. 모니터에서 나오는 빛을 인식하고, 그에 대한 행동을 연속적으로 입력해주는게 일반적으로 보이는 컴퓨터의 사용방식이다. 그 중 게임은 모니터에서 나오는 빛들이 가장 많이 바뀌고 색들이 다채로운 컨텐츠 중 하나다. 시시각각 달라지는 동영상이라고 할 수 있겠다. 특히 긴밀하게 영향을 미치는 컨텐츠 중 하나는 게임인데, 게임에서 중요한 그래픽 비주얼은 모니터의 영향을 심각하게 받는다. HDR을 지원하는 혹은 전용 모니터가 나오기 전까지는 크게 신경쓰이는 부분은 아니였던 것 같다. 대부분 디스플레이의 _gamut_ 이 _sRGB_ 이여서, _gamut_ 을 하나만 사용하기 때문에 단순하게 _linear RGB_ 값읋 _sRGB_ 로 변환 혹은 역변환을 통해 파이프라인의 시작과 끝에서 간단하게 처리가 가능했기 때문으로 생각된다.

하지만 HDR을 지원하는, HDR 전용 모니터가 나오기 시작하면서 기존에 존재하던 SDR 디스플레이와 HDR 디스플레이는 다채로은 색을 나타내기 위해 _sRGB_ 외의  _gamut_ 을 지원하기 때문에, 모든 디스플레이를 지원하기 위해서 기존의 선형 파이프라인에서 단순하게 _ecoding/decoding curve_ 를 중간에 끼워넣는 방식이 아니라 각 디스플레이에 따라서 변환을 따로 해주는 _display mapping_ 이 필요하게 되었다.

<!-- more -->

<br/>
![legacy pipeline](/images/gdc2018hdr_legacy-pipeline.jpg){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/hdr-gdc-2018">HDR Ecosystem for Games, Evan Hart, 2018
</a>
<br/>
</center>
<br/>

<br/>
![hdr-aware pipeline](/images/gdc2018hdr_hdr-pipeline.jpg){: .center-image}
<center>출처 : <a href="https://developer.nvidia.com/hdr-gdc-2018">HDR Ecosystem for Games, Evan Hart, 2018
</a>
<br/>
</center>
<br/>


<br/>
![ACES pipeline](/images/ACES-Pipeline_Marked-614x1024.jpg){: .center-image}
<center>출처 : <a href="https://mixinglight.com/color-tutorial/getting-know-aces/">mixinglight.com : Getting To Know ACES Part 1: Introduction
</a>
<br/>
</center>
<br/>

pipeline:
  프로스트 바이트 PT 처럼 전체 파이프라인에 대한 리뷰 + HDR 의 display mapping
  ACES 전체 파이프라인

PQ, HLG,

metadata:
  표준: static, dynamic >= SMPTE ST2094, real-time 가능 (HDMI2.2)
  DXGI 1.6 버젼에서 가능한 것 체크

<!--

    gamma curve, EOFT, OEFT, perceptual quantizer, hybrid log gamma

UHD Color For Games

    Scene Refered vs Output Refered

    OETF & EOTF

  Where UHD fits with Gaming

    What your game can gain

    A practical path to utilizing UHD in the near term

    Physically-based Rendering

    Scenes that will utilize HDR well

    validating your Scene

    Scene-Referred Post Processing

    ACES-derived Tone Mapper

    Scene-Referred Color grading

    Practical Implementation

    FP16 scRGB Back Buffer

    UHD Metadata
    2018 버젼에서 SMPTE 2084 는 static, SMPTE 2094 는 다이나믹 하게 메타데이터를 바꿔서 할 수 있음.

    UI Compositing

    tone mapping in more depth
        local vs global : local 이 temporal stability + 적당한 퀄에는 꽤 많은 ㅣㅂ용 + 가끔 하이퍼리얼같음 => global tonemapper(disney local op: http://zurich.disneyresearch.com/~taydin/_resources/publication/vtm.pdf)
        luminance vs independent rgb channel tonemapping operation,
          rgb 채널은 LMS Cone 인식, peak luminance  로 갈수록 알아서 netural desaturation
          luminance 는 more colorful, art directing 이 있으면 ㄱ
        tonemapping curve 는 display output luminance range 에 따라 다랄짐.
          상황 가정 : HDR 데이터 -> SDR tonemapping curve
            1. 너무 많이 압축해서, 이미지의 채도가 낮아진다. (chroma -> duller)
            2. 해당 커브에서 나와도, 기본적으로 SDR 커브는 추가적인 공간(extra dynamic range)를 지원하지 않는 상황에서 쓰이기 때문에 [0, 1] 범위로 클리핑된다.
            3. 대부분의 씬에서의 luminance level 은 굉장히 밝게 된다. 1000nit 로 범위를 강제로 늘린 reinhard operator 를 쓴다면, middle gray 가 150nit 가 나온다. 이는 sRGB 표현에 필요한 80nit 의 대략적인 두배이며, LCD monitor 의 max luminance level 이 대부분 200~300nit 인데, 보통은 max luminance level 로 출력하지 않고 그보다 낮게 출력하기 때문에, 거의 비슷한 밝기가 필요한 것으로 알 수 있다.
        HDR 커브는 최대한 많은 범위의 mid-tone 을 압축없이 표현하게 하는것이 목표. 그래서 sdr/ldr 커브와 비교하면 그부분에서 차이가 남. higtlight 또한 넓게 표현하기 위해 덜 압축함. (압축 -> 기존의 값을 좁게 매핑하는 것.)
        결론 : ACES tonemapping curve 는 사실상의 표준, cinematric look 에 최적, color channel 적용이라서 netural desaturation of highlight
    Parameterized ACES
      ACES 는 단지 프레임워크 일 뿐이다. ODT 가 많아지면 많아질수록 이를 탑재하는 device 의 ODT 종류도 다양해진다. 이들을 커버하기 위해 reference ODT 의 Parameterized 버젼을 만들었다. 이는 쉐이더 개발/유지를 쉽게 만든다.
      Parameterization 의 가장 중요한건 "조정 가능한" ODT curve 를 만드는거다. 이는 2차 곡선, 고정된 middle gray, 입력된 luminance, 출력할 luminance 로 정의된다. 즉 이 값ㅇ르 바꾸어서 세팅도 가능하다는 것. (tweak)
      luminance 기반으로도 계산 가능하다. luminance 로 조정된 값과 RGB 로 조정된 값을 interpolation 해서 사용가능
      나머지 factor 는 display white point : 기본적으로 쓰는 illuminant D65 를 사용하고, output gamut 은 sRGB 로부터 시작해서 scRGB 간다. viewing environtment
-->

<!--
  application of color space in display
-->

## 참조

 - [UHD Color for Games, Evan Hart, 2016](https://developer.nvidia.com/sites/default/files/akamai/gameworks/hdr/UHDColorForGames.pdf)
 - [HDR Ecosystem for Games, Evan Hart, 2018](https://developer.nvidia.com/hdr-gdc-2018)
 - Advanced Techniques and Optimization of VDR Color Pipelines, Timothy Lottes, 2016
 - [High Dynamic Range color grading and display in Frostbite, Alex Fry, 2017](https://www.ea.com/frostbite/news/high-dynamic-range-color-grading-and-display-in-frostbite)
 - [SMPTE ST 2094 and Dynamic Metadata](https://www.smpte.org/sites/default/files/2017-01-12-ST-2094-Borg-V2-Handout.pdf)
