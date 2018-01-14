---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - shader
  - gpuinstancing

---

Unity 에서의 확실한 GPU Instancing 은 __ComputeBuffer__ 라는 구현체에서 시작될 것이다. 이 구현체는 __UnityEngine.ComputeBuffer__ 라는 Unity 의 구현체이며 하는 역할은 GPU 메모리를 사용하게 해주는 역할을 한다. __ComputeBuffer__ 는 __ComputeShader__ 와 함께 등장했다. __ComputeShader__ 에서 데이터를 읽고 쓰는것을 요구하기 때문에 Unity 는 GPU 메모리를 사용하는 컨테이너로서 __ComputeBuffer__ 를 구현해 놓았다. 하지만 이 __ComputeBuffer__ 는 __ComputeShader__ 뿐만아니라 일반 쉐이더에서도 폭넓게 사용가능하다. 이 말의 뜻은 우리가 생각하는 Unity 에서 지원하는 일반적인 메쉬 데이터를 사용하지 않아도 사용자가 직접 메쉬 데이터를 커스터마이징해서 사용할 수 있다는 이야기이다. 지원하는 플랫폼은 일반적으로 말하는 _Shader Model 5.0_ 이상이다. PC 플랫폼에서는 당연히 사용 가능하다.

사용하는 방법 자체는 어렵지 않다. 스크립트에서 _size_ 와 _stride_ 를 설정해주고, 데이터의 배열을 만들어 GPU 메모리 안에 있는 데이터를 읽거나 쓸 수 있다. 메모리 단위에서 하는것처럼 보이기 때문에 크기와 타입은 맞춰주어야 한다. C# 에서는 __System.Array__ 형으로 넣어주니 형태에 주의하기 바란다. 방법은 아래와 같다.

``` C#
int dataLen = ...;  // length of data
int[] dataArray = new int[dataLen];

// record data in dataArray..

ComputeShader computeShader = ...;
ComptueBuffer dataBuffer = new ComputeBuffer(dataLen, sizeof(int));
dataBuffer.SetData(dataArray);

computeShader.SetBuffer("dataBuffer", dataBuffer);
```

위 코드는 __ComputeShader__ 에서 __ComputeBuffer__ 를 사용하기 위해 세팅하는 코드다. 가장 맨처음에는 초기에 세팅할 정수 배열을 만들고, 그 다음 __ComputeBuffer__ 인스턴스를 생성한다. 생성자에서 넣어주는 인자는 데이터의 길이(_length_)와 각 데이터별 크기(_stride_)이다. 그 다음 같은 크기의 배열의 데이터를 GPU 메모리로 쓴다.(_write_) 그리고 마지막으로 데이터가 세팅된 __ComputeBuffer__ 를 __ComputeShader__ 에 연결해준다. 이러면 __ComputeShader__ 코드에서 _dataBuffer_ 라는 변수명을 가진 변수에 __ComputeBuffer__ 가 연결된다. 아래에 __ComputeShader__ 코드가 있다.

``` HLSL
StructuredBuffer<int> dataBuffer;

[numthreads(8,8,1)]
void Process (uint3 id : SV_DispatchThreadID)
{
  ...
}
```

맨 처음에 있는 _dataBuffer_ 에 연결된다. [StructuredBuffer vs ConstantBuffer]({{ site.baseurl }}{% post_url 2017-07-06-structured-buffer-vs-constant-buffer %}) 에서본 _StructuredBuffer_ 타입이 가능하다. 또한 _RWStructuredBuffer_, _ConsumeStructuredBuffer_, _AppendStructuredBuffer_ 가능하다. 다른 렌더러 쉐이더 코드에서도 사용가능하다. 그래서 일반적으로 고려되는 파이프라인은 아래와 같다.

![data process](/images/data-process-pipeline.png){: .center-image}

앞의 두가지 __ComputeBuffer__ 를 세팅하고 __ComputeShader__ 를 실행하는 코드는 대충 보았다, 뒷 부분의 __ComputeBuffer__ 를 통해 렌더링을 하는 것은 그다지 어렵지 않다. 중요한 것은 참신하게, 효율적으로 렌더링하는 것이다.

[Github : CustomSkinningExample](https://github.com/hrmrzizon/CustomSkinningExample) 에서 스키닝의 계산을 __ComputeShader__ 로 넘겨서 계산한다. 또한 메시 데이터 전체를 __ComputeBuffer__ 로 넘겨서 렌더링하기 때문에 꽤나 괜찮은 예가 될것이다.

## 참조

 - [Unity Reference : ComptuteBuffer](https://docs.unity3d.com/ScriptReference/ComputeBuffer.html)
