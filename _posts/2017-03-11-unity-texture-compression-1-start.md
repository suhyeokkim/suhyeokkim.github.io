---
layout: post
author: "Su-Hyeok Kim"
comments: true
show: true
categories:
    - unity
    - texture_compression
    - analysis
---

Unity 로 게임을 개발하던 도중 텍스쳐 압축에 호기심이 생겨 공부하기 + 호기심을 풀기 위해 텍스쳐 압축에 대해 알아보기로 하였다.

## 1\. 텍스쳐 압축(Texture Compression)이란?

#### 1) 뜻

일반적으로 압축(Compression) 이란 원본 데이터를 조금 없에거나, 보존해서 파일의 크기를 줄이는 방법을 칭한다. 대표적인 예로 우리가 큰 파일을 전송할 때 압축을 해서 전송하는 경우가 있겠다.(zip, 7z) 이러한 파일 압축 기법들은 모든 데이터를 보존해야 하기 때문에 비손실 압축으로 되어 있다. 하지만 미디어 파일(오디오, 영상, 이미지) 들은 모든 데이터를 저장하지 않고 사람이 인식할 정도만 데이터를 저장하는 비손실 압축 기법이 대부분을 차지한다. (mp3, mp4, jpg) 비 손실 압축방법 중 잘 알려진 포맷은 PNG 포맷이 있다. JPEG, PNG 방식들은 통칭 이미지 압축(Image Compression) 이라 부른다. 하지만 텍스쳐 압축과 이미지 압축의 의미는 조금 다르다.

텍스쳐 압축(Texture Compression) 위키피디아를 참조해보면 

> Texture compression is a specialized form of designed for storing in rendering systems. Unlike conventional image compression algorithms, texture compression algorithms are optimized for random access.

문장들을 해석해보면 "텍스쳐 압축은 3D 컴퓨터 그래픽스 렌더링 시스템에서 텍스쳐 맵들을 저장하기위해 고안된 특별한 방식의 이미지 압축이다. 텍스쳐 압축 알고리즘은 전통적인 이미지 압축 알고리즘과 다르게 무작위 접근에 최적화 되어있다." 라고 한다.

텍스쳐 압축 알고리즘 자체는 이미지 압축 알고리즘이라 할 수 있다. 하지만 텍스쳐 압축 알고리즘이 이미지 압축과 다른 점은 3D 렌더링 시스템에서 빠르게 접근하기 위해 이미지의 픽셀별로 빠르게 접근이 가능하다는 것이다. 빠르게 접근 한다는 뜻은, __압축된 텍스쳐 데이터 그대로에서 픽셀별로 데이터를 가져올 수 있어야 한다는 뜻이다.__

대부분의 미디어 압축 포맷에 응용되어 상당히 많이 쓰이는 [Run-Length Encoding](https://ko.wikipedia.org/wiki/%EB%9F%B0_%EB%A0%9D%EC%8A%A4_%EB%B6%80%ED%98%B8%ED%99%94), [Huffman Encoding](https://ko.wikipedia.org/wiki/%ED%97%88%ED%94%84%EB%A7%8C_%EB%B6%80%ED%98%B8%ED%99%94) 방식들은 Encode 된 상태에서 원하는 픽셀의 정보만 가져올려면 모든 데이터를 Decoding 한 후에 가져와야 한다.  즉 저 방식들이 들어간 압축 방식들은 빠른 무작위 접근이 힘들기 때문에 텍스쳐 압축 알고리즘에 응용될 수 없다.

#### 2) 쓰임새 

실제로 텍스쳐 압축을 사용하려면 요구조건이 몇가지 있다.

> 1. 그래픽 시스템(OpenGL, DirectX)에서 텍스쳐 압축을 지원해야 한다.
> 2. 해당 컴퓨터의 GPU 에서 텍스쳐 압축을 지원해야 한다.

자주 사용되는 텍스쳐 압축 방식은 그래픽 시스템에서 지원한다. 그래픽 시스템에 대한 걱정은 안해도 된다. 하지만 GPU 에서 지원하는 텍스쳐 압축 방식들은 알아야 한다. GPU 에서 지원하는 압축 포맷의 경우 압축된 데이터를 알아서 디코딩하지만, 지원 안하는 포맷의 경우 SW 디코딩을 하거나, 다른 포맷으로 바꿔주어야 한다.

스마트폰을 예로 들면, 모바일 플랫폼은 GPU 의 종류가 4가지가 넘고, GPU 별, GPU 제조사 별로 지원하는 텍스쳐 압축 방식이 다 다르다.

대표적으로 Apple 의 모바일 기기에서 쓰이는 Apple A~ 칩셋들은 모두 PowerVR GPU를 탑재했고, PowerVR GPU 는 PVRTC(PowerVR Texture Compression) 만 지원한다. Apple 제품군에서는 PVRTC 만 쓰면 된다.

이에 반해 다양한 Android 기기들은 다양한 GPU 를 탑재해서 (QualComn Adreno, ARM Mali 등..) 더욱더 다양한 종류의 텍스쳐 압축 기법이 존재한다. Android 기반의 디바이스들은 거의 다 ETC1 을 지원하기 때문에 대표적으로 사용이 가능하긴 하다. 하지만 몇몇 기기가 PowerVR GPU 를 탑재하기 때문에[^1] ETC1 만 사용할 수는 없다.

즉 하나의 모바일 어플리케이션에서 모든 방식을 선택하기는 힘들다. 모든 방식을 지원하려면 다양한 방식의 리소스가 필요한데, 그러면 응용 프로그램의 용량이 엄청나게 될 것이다. 그래서 몇 가지 디바이스를 포기하거나, Unity 에서는 [AssetBundle](https://docs.unity3d.com/kr/current/Manual/AssetBundlesIntro.html)의 힘을 빌려 [**이런 방법**](http://dragonjoon.blogspot.kr/2015/08/blog-post.html)을 쓸 수도있다.

[^1]: 대표적으로 삼성 Exynos 3110, 5410 이 있다. 쓰인 기기는 갤럭시 S, 갤럭시 탭 7.0, 갤럭시 S4
[^2]: [^Texture Compression : 위키피디아(영문)](https://en.wikipedia.org/wiki/Texture_compression)
[^3]: [^삼성 엑시노스 : 위키피디아(한글)](https://ko.wikipedia.org/wiki/%EC%82%BC%EC%84%B1_%EC%97%91%EC%8B%9C%EB%85%B8%EC%8A%A4)
[^4]: [^ARM Mali : 위키피디아(영문)](https://en.wikipedia.org/wiki/Mali_(GPU))
[^5]:[^Qualcomm Adreno : 위키피디아(영문)](https://en.wikipedia.org/wiki/Adreno)
[^6]: [^ETC : 위키피디아(영문)](https://en.wikipedia.org/wiki/Ericsson_Texture_Compression)
