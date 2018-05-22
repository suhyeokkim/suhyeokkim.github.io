---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - anisotropic
  - filtering
---

보통 사용되는 _Texture Fltering_ 들은 _Axis Align_ 된 방향을 기준으로 추가적인 샘플링을 하는 방법들이 대부분이다.(bilinear, bicubic, etc..) 하지만 특이한 것이 하나 있다. 바로 _Anisotropic Filtering_ 이다.

_Anisotropic Filtering_ 은 원거리에 있는 물체들을 선명하게 보이게 하기위해서 쓰여지는 _Fiterling_ 으로, 말보다는 아래 그림을 보는게 훨씬 직관적으로 이해할 수 있다.

<br/>
![Real-time Rendering 3rd](/images/aniso_pixel_to_texel.png){: .center-image}
<center>출처 : Real-time Rendering 3rd</a>
</center>
<br/>

위의 그림과 같이 _Texture-Space_ 에서 픽셀안에 있는 텍스쳐를 여러번 샘플링하여 평균을 구하는 방식인듯하다. 그런데 아주 중요한 것이 하나 남아있다.

<br/>
![Unsolved Problems and Opportunities for High-quality, High-perfornmance 3D Graphics on a PC Platform : Anisotropic Filtering](/images/img034.gif){: .center-image}
<center>출처 : [Unsolved Problems and Opportunities for High-quality, High-perfornmance 3D Graphics on a PC Platform : Anisotropic Filtering](http://www.graphicshardware.org/previous/www_1998/presentations/kirk/sld030.htm)
</a>
</center>
<br/>

위의 그림을 보면 알겠지만 _bilinear filtering_ 과 함께 쓸 경우 엄청난 샘플링 부하가 생길 것이라는 것을 예상할 수 있다.

_Anisotropic Filtering_ 을 처음 접했을 떄, 가장 이해가 가지 않았던 것은 결국 내부에서 샘플링을 해야할 텐데 어떤 방식으로 방향을 구할지 가장 이해가 안됬었다. 지금 다시 생각해보면, _ddx_ 키워드를 _uv_ 좌표에 쓰듯이 _Texutre-Space_ 의 차이 벡터를 쉽게 구할 수 있을 듯 하다.

## 참조

 - Real-Time Rendering 3rd
 - [Unsolved Problems and Opportunities for High-quality, High-perfornmance 3D Graphics on a PC Platform : Anisotropic Filtering](http://www.graphicshardware.org/previous/www_1998/presentations/kirk/sld030.htm)
