---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - rendering
  - post-processing
  - hdr
---

꽤 오래전부터 게임에서의 _post-processing_ 은 굉장히 중요한 요소로 자리잡았다. 아무리 _geometry(mesh)_ 들을 잘 나타내더라도 모니터에서 출력되는 픽셀단위로 표시되는 빛이 사람의 눈에 어떻게 보이느냐가 중요하기 때문이다. 이를 처리하기 위한 배경과 각각의 개념이 무엇을 뜻하는지 적어보겠다.



<!--

  일반적인 1byte 고정 부동소수점의 한계
  2byte half floating point
  dynamic range :
-->

<br/>
![Gamma correction](/images/An+image+comparing+gamma+and+linear+pipelines.png){: .center-image}
<center>출처 : <a href="http://www.kinematicsoup.com/news/2016/6/15/gamma-and-linear-space-what-they-are-how-they-differ">GAMMA AND LINEAR SPACE - WHAT THEY ARE AND HOW THEY DIFFER</a>
</center>
<br/>


## 참조

 - [High Dynamic Range Rendering on the GeForce 6800](http://download.nvidia.com/developer/presentations/2004/6800_Leagues/6800_Leagues_HDR.pdf)
 - [Photography stackexchange : What is tone mapping? How does it relate to HDR?](https://photo.stackexchange.com/questions/7630/what-is-tone-mapping-how-does-it-relate-to-hdr)
 - [GAMMA AND LINEAR SPACE - WHAT THEY ARE AND HOW THEY DIFFER](http://www.kinematicsoup.com/news/2016/6/15/gamma-and-linear-space-what-they-are-how-they-differ)
 - [Wikipedia : Exposure Compensation](https://en.wikipedia.org/wiki/Exposure_compensation)
 - [Wikipedia : Tone mapping](https://en.wikipedia.org/wiki/Tone_mapping)
 - [Wikipedia : Dynamic range](https://en.wikipedia.org/wiki/Dynamic_range)
 - [Wikipedia : High-dynamic-range rendering](https://en.wikipedia.org/wiki/High-dynamic-range_rendering)
 - [Computer Graphics stackexchange : Tone Mapping & Gamma Correction](https://computergraphics.stackexchange.com/questions/5449/tone-mapping-gamma-correction)
 - [NVidia : UHD Color for Games](https://developer.nvidia.com/sites/default/files/akamai/gameworks/hdr/UHDColorForGames.pdf)
 - [Color spaces - REC.709 vs. sRGB](https://www.image-engineering.de/library/technotes/714-color-spaces-rec-709-vs-srgb)
