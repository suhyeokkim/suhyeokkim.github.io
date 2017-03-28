---
layout: post
author: "Su-hyeok Kim"
comments: true
show: true
categories:
    - unity
    - texture_compression
---

#### 이 글은 [이전 블로그](jhedde.tistory.com)에서 가져온 글입니다.

모든 내용은 전부 Jacob Ström 홈페이지의 자료등을 참고했습니다.([http://www.jacobstrom.com/output.html](http://www.jacobstrom.com/output.html))

---

## 2\. ETC(Erricsson Texture Compression)

처음 알아볼 압축 방식은 ETC(Erricsson Texture Comperssion) 이다. Jacob Ström[^1], Tomas Akenine-Möller 두 사람이 학부 실저에 고안해낸 PACKMAN(2004) 을 더 발전시켜 iPACKMAN(2005) 이라는 학명으로 SIGGRAPH 라는 유명한 컨퍼런스에 등장했다. 이 후 iPACKMAN 의 공식 명칭이 Errcisson Texture Compression(ETC1) 으로 되어 쓰이게 된다. ETC 를 알아보기 전, 먼저 고안된 PACKMAN 을 알아보기로 하자.

#### (1) PACKMAN?

PACKMAN 은 블록 방식의 텍스쳐 압축 기법으로, 직사각형 픽셀 그룹을 만들어 압축한다. RGB 채널이 각각 8bit인 픽셀 8개를(2*4=8) 총 32bit로 압축시킨다. 압축을 안할 시 192bit 이니 1/6 의 공간을 차지하게 압축한다.

| ![12bit_general_color](/images/etc1_12bit_general_color.png)              | + | ![per-pixel_luminance](/images/etc1_per-pixel_luminance.png)           | + | ![packman-compressed](/images/etc1_packman-compressed.png) |
| :-----: | :-----: | :-----: | :-----: | :-----: |
| 12bit general color |  | per-pixel_luminance | | packman-compressed |
| | | | | |

PACKMAN 의 정보는 블록에서 평균색(첫번째 그림:general color)과 색 편차가 들어가 있는 테이블의 인덱스를 픽셀별로 기록해(두번째 그림:per-pixel luminance) 평균 색 + 색 편차로 각 픽셀의 색을 결정해 텍스쳐를 구성한다.(세번째 그림:packman-compressed)

평균색은 말 그대로 픽셀들간의 평균 색이고, 색 편차는 픽셀별로 다른 색들을 평균 색과 비교해서 가장 가까운 편차를 선정한다. 위 문단에서 테이블의 인덱스를 기록한다고 했는데 더 자세하게 알아보기 위해 테이블을 가져왔다.

![luminancetable](/images/etc1_luminance_table.png)

위 표는 자주 사용될만한 색 편차들을 정해놓은 표다. 원래는 4개의 숫자가 한개의 세트로 16세트로 구성되어 있으나, 위 표에는 앞의 8개만 나와있다.

색 편차 데이터가 구성되는 방식은 8개의 픽셀들간에 가장 오차가 적을만한 table codeword 를 선정한 후 4개의 데이터 중 하나를 골라 인덱스를 저장한다. 색편차를 저장하는 데이터의 종류는 table codeword 와 그 세트안의 인덱스 정보 두개다. 또한 픽셀 인덱스는 픽셀별로 필요하기 때문에 8개가 필요하다.

색 편차 데이터의 구성 방식을 알아보았으니 전체 색 구성 방식을 알아보자. 필요한 정보와 데이터의 크기는 아래와 같다.

> 1. 픽셀간의 평균색 : RGB444(12bit)
> 2. 테이블 코드워드 : 0~15(4bit)
> 3. 픽셀별 인덱스 : 0~3(2bit)

평균색은 RGB444 방식으로 12bit로 표현되며, table codeword 는 총 16개가 있으니 4bit 가 필요하다, 그리고 픽셀별 인덱스는 4가지의 숫자만 표현하면 되니 2bit 면 충분하다. 그래서 8개의 픽셀색을 표현하는데 필요한 비트는 12+4+2*8= 32bit 가 필요하다.

#### (2) iPACKMAN?

PACKMAN 압축 방식은 문제가 있었다. PACKMAN 방식으로 압축된 이미지와 각 픽셀당 RGB444 로 압축된 이미지를 비교했을 때 휘도(luminance)만 보면 더 좋은 결과를 보여주었지만 색차(chrominance) 면에서 보면 더 안좋은 결과를 보였다. 특히 그라데이션 같이 색이 천천히 바뀌는 이미지에서 색차 밴딩(chrominance banding)이 심했다고 한다. RGB444 방식을 사용해서 작은 차이를 표현하기 어렵고, 한 블록(8개의 픽셀)당 한개의 RGB444 색만 사용하기 때문이다.

그래서 iPACKMAN 에서는 색차 밴딩을 해결하기 위해 PACKMAN 의 방식에서 변형된 모드를 하나 추가했다. 그 모드 때문에 꽤 많은 부분이 바뀌었다. 모드를 제외한 변경사항은 아래와 같다.

> 1. table codeword 가 3bit 로 줄었다.
> 2. 블록의 개념이 2*4 픽셀 그룹 하나에서 2*4 픽셀 그룹 두개를 합친 4*4 픽셀 그룹으로 확장됬다.

위에서 색차 밴딩이 심하다고 언급했다. 그리고 원인은 RGB444 에 있다고도 말했다. 그래서 데이터의 정밀도를 높이기 위해, 두 2*4 픽셀 그룹의 공간을 합쳐 기존에 독립적으로 2개의 RGB444 색상이 구성되던 방식과 달리 약간의 변화를 주어 RGB555+dRGB333 으로 데이터를 구성하는 방식을 고안해냈다.

RGB444의 한계를 느끼고 RGB555 로 평균 색을 확장해서 색차의 범위를 확인했다. 20개의 서로 다른 이미지들의 색 편차(deviation)의 통계 데이터를 확인해보자.

| ![histogram_difference](/images/etc1_histogram_difference_average_color.png) |
| :---: |
| RGB555로 양자화된 평균 색상의 편차 그래프 |
| |

데이터를 보면 대부분 가운데에 몰려있다. 그래서 88%의 데이터를 포함가능한 -4 ~ 3 간격을 타겟으로 RGB555 를 사용후, RGB333 을 편차값으로 사용해 두 블록을 사용하는 방법을 사용했다.

table codeword 가 3bit 로 줄은 이유는 이미지를 표현할 공간을 만들어야 했기 때문에 다른 것들을 살피다가 table codeword 를 줄인것으로 예측된다. table codeword 는 고정된 색상 편차 테이블의 인덱스인데, 20개의 이미지 테스트에서 3bit 로 줄이는 테스트를 해 보았을 때, 놀랍게도 평균 0.2db 차이가 안나 바꾸었다고 한다.

table codeword 의 사이즈를 1bit 씩 줄여 2*4 픽셀 그룹이 2개니 2bit 여유 공간이 남았다. 이 공간들은 데이터의 구성을 표현하는 데이터가 된다. 1bit 는 새롭게 추가된 difference mode 냐, normal mode 냐를 표현하는 비트 플래그로, 1bit 는 수직으로 데이터가 구성되는지, 수평으로 데이터가 구성되는지에 대한 비트 플래그로 표현했다.

직관적으로 데이터 구성을 이해하기 위해 논문에 있던 이미지를 첨부하겠다.

| ![histogram_difference]({{ site.url }}/images/etc1_table_diff_vs_normal.png) |
| :---: |
| 데이터 구성 |
| |

#### (3) 특징

ETC 의 특징은 아래와 같다.

> 1. 모바일 디바이스를 기준으로 한 손실 압축 기법이다.
> 2. 투명하지 않은(Non-Alpha) 텍스쳐(RGB24)를 지원한다. 
> 3. OpenGL ES 2.0 이상 부터 표준 포맷이 되었으며, 안드로이드 프로요(2.2) 부터 공식 지원하기 시작했다.

ETC 는 기본적으로 모바일 디바이스를 타겟으로 만들어진 텍스쳐 압축 알고리즘이다. 그렇기에 구현 방식 또한 상당히 간단하고 명료하다. 보통 ETC 는 OpenGL ES 3.0 아래 버젼을 지원하는 GPU 를 탑재한 디바이스를 지원할 때 주로 사용되는 방식이다. 또한 알파를 설정할 수 없어 상당히 불편한 경우가 많다.

[^1]: 이 사람은 추후 ETC2 연구에도 참여하였다.
