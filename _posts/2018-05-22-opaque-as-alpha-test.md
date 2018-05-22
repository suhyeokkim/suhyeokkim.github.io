---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - rendering
  - alphatest
  - shader
---

_Shader_ 에서 샘플링하는 _Texutre_ 에서 _Alpha_ 값을 가지고 있어, _Alpha_ 을 참조해서 실제 픽셀에 출력을 하는지 안하는지를 결정하는 것을 _Alpha Test_ 라고 한다. 이런 _Material_ 이나 _Texture_ 를  _Cutout_ 이라고 통칭하는 경우가 많다.

보통 게임에서의 _Alpha Test_ 를 사용하는 것들은 나무, 풀 같은 식생들(_Vegetation_)이 있고, 중간에 구멍이 뚫린 펜스같은 것들도 존재한다. 자연을 배경으로하는 게임의 경우에는 식생들이 굉장히 많기 때문에 _Alpha Test_ 를 사용하는 _Shader_ 가 굉장히 많이 사용될 것이다.

<br/>
![Wikipedia : Single-precision floating-point format](/images/1_8EKqWSOOPXaTrDHVFTACJg.png){: .center-image}
<center>출처 : <a href="https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f">Anti-aliased Alpha Test: The Esoteric Alpha To Coverage</a>
</center>
<br/>

하지만 _Alpha Test_ 는 굉장히 큰 단점이 있다. 고정된 화면 해상도에서 물체가 작게 표현되면 물체를 표현할 수 있는 픽셀의 숫자가 많이 작아진다. 물체를 표현하는 픽셀의 수가 작아지게 되면 일반적으로 해당 넓이에 맞게 생성된 _Texture_ 의 _Mip-level_ 에 접근한다. 중간의 _Alpha Test_ 그림을 보면된다.

<br/>
![Wikipedia : Single-precision floating-point format](/images/1_zNbZFiJXjcqqyTkM9eEt7w.gif){: .center-image}
<center>출처 : <a href="https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f">Anti-aliased Alpha Test: The Esoteric Alpha To Coverage</a>
</center>
<br/>

실제로는 양 옆의 물체들처럼 자연스럽게 표현이 되야하지만 일반적인 _Alpha Test_ 를 사용하게 되면 위와 같은 현상에 마주치게 된다. 이는 굉장히 끔찍한 현상이다. 실제 게임을 해보거나, 만들어본 사람이라면 안다. 대부분의 픽셀에 나무가 표현되고, 잎사귀들이 저런식으로 자글자글 거린다면 약간의 불쾌함이 느껴진다. VR 이라면 더욱..

그래서 급하게 대처방안으로 나온 것이 위 그림의 오른쪽에 나오는 _Alpha to Coverage_ 라는 방법이다. 이는 하드웨어 _MSAA_ 를 픽셀 쉐이더의 결과를 통해 자동으로 해주는것으로, _MSAA_ 의 퍼포먼스와 비례한다. _MSAA_ 는 성능이 영 좋지않아 안쓰는 경우가 꽤 많이 존재하기 때문에 _Alpha to Coverage_ 는 절대적으로 사용할 수 있는 방법은 아니다. 게다가 엄청나게 많은 나무를 _Alpha to Coverage_ 를 쓴다면.. 성능은 안봐도 뻔하다.

앞서 말한 _Alpha Test_ 은 _Material_, _Shader_ 별로 고정된 _Alpha_ 값을 설정해 그 이하가 되면 _Pixel Shader_ 에서 결과를 내놓지 않게 하는(_Discard_) 방법이였다. _Alpha Test_ 의 문제는 샘플링한 _Alpha_ 값이 가끔 극단적으로 낮아서 _Discard_ 되는 것인데, 이를 간단하게 해결하기 위해 요상한 방법이 등장했다.

바로 _Stochastic test_ 라는 방법이다.  

<br/>
![NVidia deverloper : Hashed Alpha Testing](/images/stochastic_sampling.png){: .center-image}
<center>출처 : <a href="https://developer.download.nvidia.com/assets/gameworks/downloads/regular/GDC17/RealTimeRenderingAdvances_HashedAlphaTesting_GDC2017_FINAL.pdf?pUIX8DXxfad7mL4zB3GOthX3r5IgGao9UWxYuYb3q9h10RXrQeYko-dEuJXJxt1hhsI9J_9KJDcCYGeWWksxlaHTrXSE825D_3izja7LUFOtzhaeBUqpn7qbwXaaGlLdbipjE3PeI3e2IMn45mQAA3OV2PD-kG2y9cecTaWE2uum2uwdHgyn0nhYiLOvlOsrUzewbK5REH7vAm3-lNWzxehw_5Tphg">NVidia developer : Hashed Alpha Testing</a>
</center>
<br/>

위 그림에서 위쪽에 있는 것이 일반적인 _Alpha Test_ 인데, _color.a_ 는 텍스쳐에서 샘플링한 _Alpha_ 값, _ατ_ 는 _Alpha Test_ 를 위한 고정된 _Alpha Threshold_(_알파한계_)다. 밑의 코드에서 _drand48_ 이 나타내는 것은 단순한 0 ~ 1 사이의 랜덤값이다. 즉 랜덤하게 _Alpha Threshold_ 를 설정해주어 물체가 멀어져서 평균 _Alpha_ 값이 낮아질 때도 픽셀이 _Discard_ 되지 않도록 하는 것이다.

하지만 이는 굉장한 눈아픔? 반짝거림? 을 유발한다. 범위를 지정해주지 않았기 때문에 이전 프레임에서 출력된 픽셀이 다음 프레임에서는 출력되지 않을 수도 있다. 이렇게 각 프레임마다 상황이 달라서 생기는 현상앞에 _Temporal_ 을 붙인다. _Stochastic Alpha Test_ 의 문제는 _Temporal Flickering_ 이라고 할 수 있겠다.

_Temporal Stability_(임시적 안정성) 을 확보하기 위해서는 _Alpha Threshold_ 를 이러저리 튀지 않게해야 했고, 이를 위해 특정 값에 따라서 _Hash_ 값을 생성하는 방법이 고안되었다. 이 방법은 _Hashed Alpha Test_ 라는 이름으로 작년에 공개되었다.

<!--
  Hashed Alpha Test
  Alpha Distribution
-->

## 참조

 - [Anti-aliased Alpha Test: The Esoteric Alpha To Coverage](https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f)
 - [NVidia developer : Hashed Alpha Testing](https://developer.download.nvidia.com/assets/gameworks/downloads/regular/GDC17/RealTimeRenderingAdvances_HashedAlphaTesting_GDC2017_FINAL.pdf?pUIX8DXxfad7mL4zB3GOthX3r5IgGao9UWxYuYb3q9h10RXrQeYko-dEuJXJxt1hhsI9J_9KJDcCYGeWWksxlaHTrXSE825D_3izja7LUFOtzhaeBUqpn7qbwXaaGlLdbipjE3PeI3e2IMn45mQAA3OV2PD-kG2y9cecTaWE2uum2uwdHgyn0nhYiLOvlOsrUzewbK5REH7vAm3-lNWzxehw_5Tphg)
