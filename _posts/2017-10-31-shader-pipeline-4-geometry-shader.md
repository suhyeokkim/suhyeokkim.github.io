---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - render
  - shader
  - hlsl
---

"[Fragemnt Shader]({{ site.baseurl }}{% post_url 2017-10-31-shader-pipeline-3-fragment-shader %})" 에서 _Fragment Shader_ 에 대해 알아보았다. 다음은 _Geometry Shader_ 에 대해서 써보려 한다.

_Geometry Shader_ 는 쉐이더 파이프라인에서 _Rasterizer Stage_ 넘어가기 전의 _Geometry Stage_ 의 마지막 단계로써 이전 쉐이더에서 넘긴  _Primitive_ 데이터(point, line, triangle..)를 프로그래머가 원하는 복수의 _Primitive_ 데이터로 변환할 수 있다. 삼각형을 삼각형의 중심을 나타내는 점으로 변환하는 쉐이더를 보자.

``` C
[maxvertexcount(1)]
void geom(vertexOutput input[3], inout PointStream<geometryOutput> pointStream)
{
    geometryShaderOutput o;

    o.vertex = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

    pointStream.Append(o);
}
```

매우 간단한 코드다. 간략하게 설명하자면, 맨 윗줄의 _maxvertexcount_ 는 해당 지오메트리 쉐이더에서 _Stream_ 으로 넘길 정점별 데이터의 갯수를 뜻한다. _Geometry Shader_ 한번당 _Stream_ 으로 넘길 _maxvertexcount_ 의 한계는 정해지지 않았지만 크기는 1024 바이트로 정해져 있기 때문에 적절하게 사용해야 겠다. 그 다음줄의 인자들에 대해서 설명하면, 첫번째 _vertexOutput input[3]_ 은 정해진 프리미티브의 값들을 뜻한다. 여기서는 삼각형을 기준으로 만들었기 때문에 정점별 정보가 3개가 있다. _inout PointStream<geometryOutput> pointStream_ 은 _Geometry Shader_ 의 최종 출력을 해주는 오브젝트다. _PointStream_ 은 점 프리미티브의 데이터를 받는 _Stream_ 으로써, 프리미티브가 다르면 각자 다른것을 사용할 수 있다.([MSDN : Getting Started with the Stream-Output Stage](https://msdn.microsoft.com/en-us/library/windows/desktop/bb205122.aspx)) 부등호 안에 있는 것은 일반적으로 알려진 제너릭이나 템플릿의 형태와 같으니 안에 출력으로 넘길 구조체를 넘겨주면 된다. 함수의 내용은 삼각형을 구성하는 각 정점의 위치의 평균을 구해 하나의 정점 정보만 _Stream_ 에 넘긴다.

_Stream_ 은 총 두가지의 역할을 한다. 하나는 _Rasterizer_ 단계로 넘겨서 쉐이더에서 처리를 할 수 있게 하는 통로 역할을 하고, 다른 하나는 드라이버 레벨에서 데이터를 출력해주는 통로 역할을 한다. 두가지의 일을 하기 때문에 _Stream_ 의 개념으로 추상화한 것인가 싶다. 그리고 하나의 _Geometry Shader_ 에서 여러개의 _Stream_ 으로 출력이 가능하긴 하다. 최대 4개의 _Stream_ 을 사용할 수 있다. _Stream_ 을 선택해서 데이터를 받아올 수도 있으며, _Rasterizer_ 로 보낼수도 있다. 자세한 사항은 [MSDN : How To: Index Multiple Output Streams ](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471424.aspx) 에서 확인하면 되겠다.

활용할 수 있는 다른 기능이 하나 더 있다. _instance_ 기능이다. 아래 코드를 보자.

``` C
[instance(3)]
[maxvertexcount(1)]
void geom(vertexOutput input[3], uint InstanceID : SV_GSInstanceID, inout PointStream<geometryOutput> pointStream)
{
    geometryShaderOutput o;

    o.vertex = input[InstanceID].vertex;

    pointStream.Append(o);
}
```

해당 코드는 삼각형의 세개의 정점 위치를 넘기는 코드다. 달라진 것은 _instance(3)_ 코드가 붙고, _uint InstanceID : SV_GSInstanceID_ 파라미터가 생겨 코드 안에서 이를 활용한다. _instance(x)_ 에 들어가는 x 는 반복하는 횟수를 뜻하고, _InstanceID_ 파라미터는 반복하는 인덱스를 뜻한다. 같은 입력을 여러번 받아서 일정한 수만큼 반복하는 것이다.  _instance_ 속성에 들어가는 숫자의 한계는 32까지다.

_Geometry Shader_ 는 _Shader Model 4.0_ 에서 추가되었으며 뒤에 추가적으로 알아본 _multiple stream_ 과 _instance_ 키워드는 _Shader Model 5.0_ 에서 확장된 기능들이다.

# 참조 자료

 - [MSDN : Geometry-Shader Object](https://msdn.microsoft.com/ko-kr/library/windows/desktop/bb509609.aspx)
 - [MSDN : Getting Started with the Stream-Output Stage](https://msdn.microsoft.com/en-us/library/windows/desktop/bb205122.aspx)
 - [MSDN : How To: Index Multiple Output Streams](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471424.aspx)
 - [MSDN : How To: Instance a Geometry Shader](https://msdn.microsoft.com/en-us/library/windows/desktop/ff471425.aspx)
 - [GameDev : limit on maxvertexcount() GS](https://www.gamedev.net/forums/topic/600141-limit-on-maxvertexcount-gs/)
