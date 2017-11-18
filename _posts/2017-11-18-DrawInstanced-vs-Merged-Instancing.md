---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - hlsl
---

[GDC 2014 : Vertex Sahder Tricks](https://www.gdcvault.com/play/1020624/Advanced-Visual-Effects-with-DirectX) 슬라이드에 따르면 _DrawInstanced_ 함수를 사용하여 인스턴싱을 하는것보다 _vertexID_ 를 사용하여 인스턴싱을 하는것이 빠르다고 한다. _vertexID_ 를 쓰는 방법은 굉장히 단순하다.

```
VSOutput VS(uint id : SV_VertexID)
{
    VSOutput output;

    /*
        ...
    */

    return output;
}
```

_SV\_VertexID_ _Semantic_ 을 사용하여 값을 접근하기만 하면 된다. _vertexID_ 는 말그대로 버텍스별 인덱스를 뜻한다. _SRV_ 나 _UAV_ 와 함께 사용하여 _Instancing_ 을 하면된다.

<br/>
![Merge Instancing Performance](/images/gdc2014_vertexshadertricks_23.png)
<center>출처 : <a href="https://www.gdcvault.com/play/1020624/Advanced-Visual-Effects-with-DirectX">GDC 2014 : Vertex Sahder Tricks</a>
</center>
<br/>

그림을 보면 AMD GPU 에서 확실히 퍼포먼스 차이가 난것을 확인할 수 있다. ~~스피커가 AMD 소속이라는 게 포인트~~

# 참조 자료

 - [GDC 2014 : Vertex Sahder Tricks](https://www.gdcvault.com/play/1020624/Advanced-Visual-Effects-with-DirectX)
