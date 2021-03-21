---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - opengles
  - optimization
---

※ [docs.nvidia : OpenGL ES Programming Tips](https://docs.nvidia.com/drive/drive_os_5.1.6.1L/nvvib_docs/index.html#page/DRIVE_OS_Linux_SDK_Development_Guide/Graphics/graphics_opengl.html)의 내용을 번역하는 포스팅입니다. 시간이 꽤 지난 내용으로 글의 내용은 현재 상황과 다를 수 있습니다. 또한 모든 내용이 번역되어 있지 않을 수도 있습니다.

<!-- more -->

This topic is for readers who have some experience programming OpenGL ES and want to improve the performance of their OpenGL ES application. It aims at providing recommendations on getting the most out of the API and hardware resources without diving into too many architectural details.

해당 주제는 OpenGL ES 의 익숙한 경험을 가지고 있고 OpenGL ES 응용프로그램의 성능을 향상시키고 싶어하는 독자를 위해 작성되었습니다. 해당 문서는 아키텍쳐적인 디테일에 너무 들어가지 않고 API와 하드웨어 자원을 최대한 활용하는 방법을 제공하는 것에 초점이 맞춰져 있습니다.

# 프로그래밍 효율

Some of the recommendations in this topic are incompatible with each other. One must consider the trade-offs between CPU load, memory, bandwidth, shader processing power, precision, and image quality. Premature assumptions about the effectiveness of trade-offs should be avoided. The only definite answers come from benchmarking and looking at rendered images!

이 토픽의 몇몇 사항들은 서로 호환되지 않습니다. 반드시 CPU 부하, 메모리, 대역폭, 쉐이더 처리 능력, 정확도, 이미지 퀄리티 사이의 trade-off 를 고려해야 합니다. trade-off의 효율에 대하여 섣부른 가정은 피해야 합니다. 오직 결정론적인 답은 벤치마킹과 렌더링된 이미지를 봄으로써 알 수 있습니다. 

The items below are not ordered according to importance or potential performance increase. The identifiers in parentheses exist only for reference.

아래의 항목은 중요성 혹은 잠재적인 성능 향상에 대해 정렬되지 않았습니다. 레퍼런스를 위해 괄호안의 식별자만 제공됩니다.

# 상태

Inefficient management of GL state leads to increased CPU load that may limit the amount of useful work the CPU could be doing elsewhere. Reducing the number of times rendering is paused due to GL state change will increase the chance of realizing the potential throughput of the GPU. The main point in this section is: do not modify or query GL state unless absolutely necessarily.

_GL state_ 의 비효율적인 관리는 CPU 부하를 증가시키고, 이는 어디서든 CPU의 유용한 일을 제한시키게 될 것입니다. _GL State_ 의 상태 변경을 위한 렌더링이 일시 중지되는 경우를 줄이는 것은 GPU의 잠재적인 처리량을 실현시킬 기회를 늘릴 수 있습니다. 이 섹션에서 중요한 점은, 완전히 필요한 경우가 아니라면 _GL state_ 를 바꾸거나 query하지 않는 것입니다.

## 쓸모없이 _GL State_ 를 변경하지 마십시오. (S1)

All relevant GL state should be initialized during application initialization and not in the main render loop. For instance, occasionally glClearDepthf, glColorMask, or glViewport finds its way into the application render loop even though the values passed to these functions are always constant. Other times they are set unconditionally in the loop, just in case their values have changed per frame. Only call these functions when the values actually do need to change. Additionally, do not automatically set state back to some predefined value (e.g., the GL defaults). That idiom might be useful while developing your application as it makes it easier to re-order pieces of rendering code, but it should not be done in production code without a very good reason.

모든 관련된 _GL state_ 는 메인 렌더링 루프가 아닌 응용프로그램의 초기화 동안 초기화 되어야 합니다. 예를 들면, _glClearDepthf, glColorMask, glViewport_ 는 전달되는 값이 항상 상수이더라도, 렌더링 루프에 들어갑니다. 다른 때에 프레임별로 값이 달라지는 케이스만 고려하여 루프에서 조건없이 계속 세팅됩니다. 값이 진짜로 바뀔 때, 함수를 호출하십시오. 추가적으로, GL에 의해 미리 제공된 값으로 자동으로 _GL state_ 를 돌리지 마세요. 이는 당신의 응용 프로그램을 개발할 때 렌더링 코드 조각을 재정렬하기 쉽게 만들어주므로 유용하지만, 아주 중요한 이유 없이는 제품의 코드에 들어가서는 안됩니다.

## 렌더 루프에서 _GL state_ 쿼리를 피하십시오 (S2)

When a GL context is created, the state is initially well-defined. Every state variable has a default value that is described in the OpenGL ES specification ("State Tables"). Except when compiling shaders, determining available extensions, or the application needs to query implementation specific constants, there should be no need to query any GL state. These queries can almost always be done in initialization. Well-written applications check for GL errors in debug builds. If no errors are reported as a result of changing state, it is assumed that the changes are now part of the new GL state. For these two reasons, the current state is always known and you should almost never need to query any GL state in a loop. If an application frequently calls functions that begin with glIs* or glGet*, these calls should be tracked down and eliminated.

_GL context_ 가 생성되었을 때, _GL state_ 는 초기에 잘 정의되어 있습니다. 모든 _GL state_ 의 변수는 OpenGL ES 스펙에("State Tables") 묘사되어 있는 기본 값으로 설정되어 있습니다. 쉐이더를 컴파일 할 때, 가능한 확장을 결정하는 때, 응용 프로그램이 특정 상수를 가져오는 구현이 필요할 때를 제외하면 _GL state_ 를 쿼리할 필요는 없습뇌다. 이 쿼리들은 초기화 과정에서 거의 끝나있기 때문 입니다. 잘 정의된 응용 프로그램은 디버그 빌드 시에 GL 에러를 체크합니다. 이러한 두가지 이유 덕분에 현재 상태는 언제나 알고 있고, 루프에서 GL 상태를 쿼리할 필요가 '절대' 없습니다. 만약 응용 프로그램이 glIs*, glGet* 같은 함수를 빈번하게 호출한다면, 추적하고 제거해야 합니다.

## 공유된 상태를 한번에 실행하십시오. (S3)

An efficient approach to reduce the number of state changes is batching together all draw calls that use the same state (shaders, blending, textures, etc.). For instance, not batching on the shader changes has the form:
_GL state_ 의 상태 변경을 줄이는 효과적인 접근 방법은 같은 상태를 공유하는(쉐이더, 블렌딩모드, 텍스쳐, 등..) _drawwcall_ 을 한번에 합쳐서 실행하는(_batch_) 것입니다. 예를 들면 쉐이더 변화를 배칭하지 않은 것은 아래와 같은 형태를 띕니다:

```
[ UseProgram(21), DrawX1, UseProgram(59), DrawY1, UseProgram(21), DrawX2, UseProgram(59), DrawY2 ]
```

Batching on the shaders leads to an improvement (fewer shader changes):

쉐이더로 배칭하면 다음과 같이 개선시킬 수 있습니다.(적은 쉐이더 변경):

```
[ UseProgram(21), DrawX1, DrawX2, UseProgram(59), DrawY1, DrawY2 ]

```

It is quite effective to group draw calls based on the shader programs they use. Reprogramming the GPU by switching between shaders is a relatively costly operation. Within each batch, a further optimization can be made by grouping draw calls that use the same uniforms, texture objects and other state. Generating a log of all function calls into the OpenGL ES API is a good approach for revealing poor batching. A tool such as PerfHUDES can conveniently generate this log without rebuilding the GL application; no change to the source code is necessary.

사용하는 쉐이더 프로그램을 기반으로 _drawcall_ 을 모으는 것은 꽤 효과적입니다. 쉐이더에 따른 변경으로 GPU를 재-프로그래밍 하는 것은 상대적으로 값 비싼 연산입니다. 같은 uniform, 같은 텍스쳐 오브젝트, 이외의 같은 상태를 가진 것끼리 묶는 각각의 _batch_ 를 통하여 더 나은 최적화를 할 수 있습니다. PerfHUDES 같은 도구는 GL 응용 프로그램을 다시 만드는 것 없이 편리하게 이런 로그를 만들 수 있어 소스 코드를 변경할 필요가 없습니다.

## 바인딩 할 때 오브젝트 별 상태를 반복하지 마십시오. (S4)

Recall that some state is bound to the object it affects. As that state is stored in the object, you do not need to repeat it when you rebind the object. A very common mistake is setting the texture parameters for filtering and wrapping every time a texture object is bound. Another common mistake is updating uniform variables that have not changed value since the last time the particular shader program was used. In particular, when batching opportunities are limited, repeating per object state generates enormously inefficient GL code that can easily have a measurable impact on framerate.

다시 말하자면, 어떤 상태는 영향을 받는 오브젝트에 바인딩 되어 있습니다. 그 상태는 오브젝트의 상태에 저장되어 있으므로, 다시 오브젝트를 바인딩 할때, 이를 반복할 필요가 없습니다. 가장 일반적인 실수는 텍스쳐 오브젝트를 바인딩 할 때 모든 경우에 필터링과 래핑 텍스쳐 파라미터를 설정하는 것입니다. 다른 일반적인 실수는 특정 쉐이더가 마지막으로 사용되었고 값이 바뀌지 않았을 때, uniform 변수에 업데이트 하는 것입니다. 특히 배칭할 기회가 제한되어 있을 때, 오브젝트 상태를 반복하는 것은 프레임레이트에 관측가능한 임팩트를 쉽게 측정 가능한 방대한 비효율적인 GL 코드를 생성합니다.

## backface culling 은 가능하면 켜십시오. (S5)

Always enable face culling whenever the back-faces are not visible. Rendering the back-faces of primitives is often not necessary.

표면의 뒷면이 안보일 때는 언제나 _face culling_ 을 켜십시오. 프리미티브의 뒷면을 그리는건 거의 필요 없습니다.

Note: The default GL state has backface culling disabled, so this is one state that should almost always be set during application initialization and be left enabled for the application lifetime.

참고: 기본적인 _GL state_ 는 _backface culling_ 이 꺼져 있기에, 응용 프로그램을 초기화 할때 거의 대부분 한 상태에 이를 적용시켜야 하고 응용 프로그램이 켜진 동안에 항상 켜져 있어야 합니다.

# 기하

The amount of geometry, as well as the way it is transferred to the GL, can have a very large impact on both CPU and GPU load. If the application sends geometry inefficiently or too frequently, that alone can create a bottleneck on the CPU side that does not give the GPU enough data to work efficiently. Geometry must be submitted in sizable chunks to realize the potential of the GPU. At the same time, geometry should be minimally defined, stored on the server side, and it should be accessed in a way to get the most out of the two GPU caches that exist before and after vertices are transformed.

기하의 양과 GL로 전송되는 방법은 CPU/GPU 부하에 아주 많은 영향을 끼친다. 만약에 응용프로그램이 기하를 비효율적으로 혹은 너무 자주 보낸다면, 그것 만으로도 CPU 쪽에서 GPU가 충분히 효율적으로 일하게에 불충분하게 전송하는 병목이 생길 수 있다. 기하는 반드시 GPU의 잠재적인 성능을 현실화하기 위해 큰 덩어리로 보내져야 합니다. 동시에 기하는 최소한으로 정의되어야 하며, 서버에 저장되어야 하고, 정점이 변환된 전후에 존재하는 두 GPU 캐시를 최대한 활용하는 방법으로 엑세스 되어야 합니다.

## 인덱스된 프리미티브를 이용하십시오. (G1)

The vertex processing engine contains a cache where previously transformed vertices are stored. It is called Post-TnL vertex cache. Taking full advantage of this cache can lead to very large performance improvement when vertex processing is the bottleneck. To fully utilize it, it is necessary for the GPU to be able to recognize previously transformed vertices. This can only be accomplished by specifying indexed primitives for the geometry. However, for any non-trivial geometry the optimal order of indices will not be obvious to the programmer. If some geometry is complex, and the application bottleneck is vertex processing, then look into computing a vertex order that maximizes the hit ratio of the Post TnL cache. The topic has been thoroughly studied for years and even simple greedy algorithms can provide a substantial performance boost. Good results have been reported with the algorithm described at the below locations.

정점 처리 엔진은 이전에 변환된 정점을 저장하는 캐시를 가지고 있습니다. 이는 Post-T&L 정점 캐시로 불립니다. 이 캐시를 최대한으로 이용하는 것은 버텍스 처리에 병목이 있을 때 매우 큰 성능 향상을 이뤄낼 수 있습니다. 최대한 사용하기 위해, GPU에서는 이전에 변환된 정점을 확인하는 것이 필요합니다. 이는 기하를 위해 인덱싱된 프리미티브를 명시하는 것으로 이뤄질 수 있습니다. 하지만 어떤 중요한 가히를 위해 인덱스의 최적화된 순서는 프로그래머에겐 중요하지 않을 수 있습니다. 만약 어떤 기하가 복잡하고 응용 프로그램이 정점 처리에 병목이 있다면 Post T&L 캐시의 히트율을 최대화 하기 위해 정점의 순서를 살펴보세요. 이 토픽은 몇년간 전체적으로 연구되었고, 심지어 간단한 그리디 알고리즘으로 실질적인 성능 향상을 제공합니다. 아래 언급된 알고리즘은 좋은 결과를 보고한 적 있습니다.

| document | URL to latest |
| ----- | ----- |
| Linear-Speed Vertex Cache Optimisation, by Tom Forsyth, RAD Game Tools (28th September 2006) | [URL](https://tomforsyth1000.github.io/papers/fast_vert_cache_opt.html) |

There is a free implementation of the algorithm in a library called vcacne.

이는 vcacne 이라는 라이브러리에 무료로 제공되어 있습니다.

Note: The number of vertex attributes and the size of each attribute may determine the efficiency of this cache—it has storage for a fixed number of bytes or active attributes, not a fixed number of vertices. A lot of attribute data per vertex increases the risk of cache misses, resulting in potentially redundant transformations of the same vertices. 

참고:  많은 버텍스 어트리뷰트와 각각의 어트리뷰트의 크기는 이 캐시의 효율성을 결정할 것입니다―이는 고정된 수의 정점의 갯수가 아닌 고정된 바이트 혹은 활성된 어트리뷰트를 가지고 있기 때문입니다. 버텍스별 많은 어트리뷰트 데이터는 캐시 미스의 리스크를 증가시키며, 잠재적으로 같은 정점의 불필요한 변환을 일으킵니다. 

## 버텍스 어트리뷰트의 크기와 그 갯수를 줄이십시오. (G2)

It is important to use an appropriate attribute size and minimize the number of components to avoid wasting memory bandwidth and to increase the efficiency of the cache that stores pre-transformed vertices. This cache is called Pre-TnL vertex cache. For instance, you rarely need to specify attributes in 32 bit FLOATs. It might be possible to define the object-space geometry using 3 BYTEs per vertex for a simple object, or 3 SHORTs for a more complex or larger object. If the geometry requires floating-point representation, half-floats (available in extension OES_vertex_half_float.txt) may be sufficient. Per vertex colors are accurately stored with 3 x BYTEs with a flag to normalize in VertexAttributePointer. Texture coordinates can sometimes be represented with BYTEs or SHORTs with a flag to normalize (if not tiling).

메모리 대역폭을 낭비하는 것을 피하고, 변환 이전의 정점을 저장하기 위한 캐시의 효율을 높이기 위해 적절한 어트리뷰트 사이즈의 사용 및 그 수를 줄이는 것은 중요한 작업입니다. 이 캐시는 Pre T&L 정점 캐시라고 불리는데, 예를 들어, 32비트 부동소수점을 사용하는 일은 거의 없습니다. 보통 오브젝트 공간 기하를 간단한 오브젝트를 정점별로 3개의 BYTE를 사용하거나 복잡한 오브젝트의 경우 3개의 SHORT를 사용합니다. 만약에 기하가 부동소수점 표현이 필요하다면 half-precision 부동소수점이면 충분할 것입니다.(available in extension _OES_vertex_half_float.txt_) 정점별 색은 정확하게 정규화하기 위한 _VertexAttributepointer_ 플래그와 함께 3개의 BYTE에 저장합니다. 텍스쳐 좌표는 종종 정규화하기 위한 플래그와 함께 몇개의 BYTE나 몇개의 SHORT로 표현됩니다. (타일링 하지 않는 경우)

Note: The exception case that normalizing texture coordinates is not necessary if they are only used to sample a cube map texture.
참고: 예외적인 케이스는 큐브맵 텍스쳐를 샘플링 할 때만 텍스쳐 좌표가 정규화가 필요 없는 경우입니다.

Vertex normals can often be represented with 3 SHORTs (in a few cases, such as for cuboids, even as 3 BYTEs) and these should be normalized. Normals can even be represented with 2 components if the direction (sign) of the normal is implicit, given its length is known to be 1. The remaining coordinate can be derived in a vertex shader (e.g. z = SQRT(1 - x * x + y * y)) if memory or bandwidth (rather than vertex processing) is a likely bottleneck.

정점 법선은 종종 3개의 SHORT 표현되고 (몇개의 경우, cuboid의 경우, 3 BYTE로 충분합니다.) 정규화 되어야 합니다. 심지어 법선은 방향인(부호화된) 경우 길이가 1이므로 두 컴포넌트로 표현될 수 있습니다. 만약 메모리나 대역폭이 병목인 경우 남은 컴포넌트는 버텍스 쉐이더에서 계산될 수 있습니다.

An optimal OpenGL ES application will take advantage of any characteristics specific to the geometry. For instance, a smooth sphere uses the normalized vertex coordinates as normal—these are trivially computed in a vertex shader. It is important to benchmark intermediate results to ensure the vertex processing engine is not already saturated. Finally remember, if some attribute for a primitive or a number of primitives is constant for the same draw call, then disable the particular vertex attribute index and set the constant value with _VertexAttrib_ instead of replicating the data.

최적의 OpenGL ES 응용 프로그램은 기하에 대한 모든 세부적인 특성을 이용합니다. 예를 들어 매끄러운 구는 정규화된 정점 위치를 법선으로 사용 가능하고―이는 보통 정점 쉐이더에서 계산됩니다. 정점 처리 엔진이 아직 과부하 되지 않은 경우를 보장하가 위해 중간 결과를 벤치마크 하는 것은 중요합니다. 마지막으로 기억할 것은 어떤 혹은 다수의 프리미티브를 위한 어트리뷰트가 같은 _drawcall_ 에서 상수라면, 그 정점 어트리뷰트 인덱스를 비활성화 하고 데이터를 복사하는 대신 _VertexAttrib_ 와 함께 상수 값으로 설정하는 것입니다.

## 정점 어트리뷰트를 압축하십시오. (G3)

Vertex attributes normally have different sets of attributes that are completely unrelated. Unlike uniform and varying variables in shader programs, vertex attributes do not get automatically packed, and the number of vertex attributes is a limited resource. Failure to pack these attributes together may lead to limitations sooner than expected. It is more efficient to pack the components into fewer attributes even though they may not be logically related. For instance, if each vertex comes with two sets of texture coordinates for multi-texturing, these can often be combined these into one attribute with four components instead of two attributes with two components. Unpacking and swizzling components is rarely a performance consideration.

정점 어트리뷰트는 보통 서로 완전히 상관없는 다른 어트리뷰트 집합을 가집니다. 쉐이더 프로그램 내의 _uniform_ 과 _varying_ 변수와는 다르게, 정점 어트리뷰트는 자동으로 압축되어지지 않고, 버텍스 어트리뷰트의 크기는 제한된 자원입니다. 이 어트리뷰트들을 압축하는 것에 실패는 예상한 바와 다르게 빠르게 제한이 발생할 수 있습니다. 논리적으로 관련되지 않은 것이라도, 컴포넌트들을 압축하여 적은 어트리뷰트를 사용하는 것은 더 효율적입니다. 예를 들어, 각각의 정점에 여러 텍스쳐를 사용하기 위해 두개의 텍스쳐 좌표를 사용한다고 가정한다면, 두 컴포넌트를 위해 두 어트리뷰트를 사용하는 것 보다, 하나의 어트리뷰트에 4개의 컴포넌트를 결합하는 경우가 종종 있습니다. 압축을 풀고, 컴포넌트를 뒤섞는 것은 대부분 고려되지 않습니다.

## 적절한 정점 어트리뷰트 레이아웃을 선택하세요. (G4)

There are two commonly used ways of storing vertex attributes:

- Array of structures
- Structures of arrays

An __array of structures__ stores the attributes for a given vertex sequentially with an appropriate offset for each attribute and a non-zero stride. The stride is computed from the number of attribute components and their sizes. An array of structures is the preferred way of storing vertex attributes due to more efficient memory access. If the vertex attributes are constant (not updated in the render loop) there is no question that an array of structures is the preferred layout.

보통 두 방법으로 정점 어트리뷰트를 저장합니다.

- 구조체의 배열
- 배열의 구조체

__구조체의 배열__ 은 주어진 정점을 각각의 어트리뷰트에 적절한 오프셋과 _non-zero stride_ 와 함께 주어진 정점을 순차적으로 저장합니다. 이 _stride_ 는 어트리뷰트의 갯수와 각각의 크기에 따라 계산됩니다. __구조체의 배열__ 은 정점 어트리뷰트를 저장하는 더 효율적인 메모리 접근으로 선호되는 방법입니다. 만약에 정점 어트리뷰트가 상수라면(렌더 루프에서 업데이트 되지 않는다면) 당연히 __구조체의 배열__ 은 선호되는 레이아웃 입니다.

In contrast, a __structure of arrays__ stores the vertex attributes in separate buffers using the same offset for each attribute and a stride of zero. This layout forces the GPU to jump around and fetch from different memory locations as it assembles the needed attributes for each vertex. The structure of arrays layout is therefore less efficient than an array of structures in most cases. The only time to consider a structure of arrays layout is if one or more attributes must be updated dynamically. Strided writes in array of structures can be expensive relative to the number of bytes modified. In this scenario, the recommendation is to partition the attributes such that constant and dynamic attributes can be read and written sequentially, respectively. The attributes that remain constant should be stored in an array of structures. The attributes that are updated dynamically should be stored in smaller separate buffer objects (or perhaps just a single buffer if the attributes are updated with the same frequency).

반면에 __배열의 구조체__ 는 정점 어트리뷰트를 같은 어트리뷰트 오프셋과 _zero stride_ 으로 각각의 다른 버퍼에 저장합니디ㅏ. 이 레이아웃은 필요한 정점별 어트리뷰트를 조합하기 위해 GPU가 다른 메모리 위치에 점프하여 가져오게 만듭니다. __배열의 구조체__ 레이아웃은 그러므로 __구조체의 배열__ 보다 대부분의 경우에 비효율적입니다. 오직 __배열의 구조체__ 를 고려해야할 때는 하나 혹은 여러개의 어트리뷰트가 동적으로 업데이트 될 때 입니다. __배열의 구조체__ 에서 _strided_ 쓰기는 얼마만큼의 바이트가 수정된 만큼 비싸질 수 있습니다. 이 시나리오에서 추천할 방법은, 순차적으로 읽기/쓰기가 가능하도록 동적인 어트리뷰트와 정적인 어트리뷰트를 나누는 것입니다. 정적으로 남은 어트리뷰트는 __구조체의 배열__에 저장합니다. 동적으로 업데이트되는 어트리뷰트는 비교적 적인 분리된 버퍼 오브젝트에 저장되어야 합니다.(혹은 같은 주기로 업데이트 될 때 같은 버퍼에 저장합니다.)

## 일관적인 시계/반시계 순서를 사용하십시오. (G5)

The geometry winding (clockwise or counter-clockwise) should be determined up front and defined in code. The geometry face that is culled by GL can be changed with the FrontFace function, but having to switch back and forth between winding for different geometry batches during rendering is not optimal for performance and can be avoided in most cases.

기하 감기(시계 혹은 반시계 방향)는 반드시 미리 코드에서 정의되어야 합니다. GL에서 컬링된 기하 표면은 FrontFace 함수를 통하여 변경될 수 있지만 렌더링 중에 다른 기하 _batch_ 를 위해 앞뒤를 바꾸는 것은 성능에 최적이 아니며, 대부분의 경우 피할 수 있습니다.

## 항상 버텍스, 인덱스 버퍼를 사용하십시오. (G6)

Recall that vertices for geometry can either be sourced from application memory every time it is rendered or from buffers in graphics memory where it has been stored previously. The same applies to vertex array indices. To achieve good performance, you should never continuously source the data from application memory with DrawArrays. Buffer objects should always be used to store both geometry and indices. Check that no code is calling DrawArrays, and that no code is calling DrawElements without a buffer bind.
The default buffer usage flag when allocating buffer objects is __STATIC_DRAW__. In many cases this will lead to fastest access.
Note: __STATIC_DRAW__ does not mean one can never write to the buffer (although any writing to a buffer should always be avoided as much as possible). A __STATIC_DRAW__ flag may in fact be the appropriate usage flags, even if the buffer contents are updated every few frames. Only after careful benchmarking and arriving at conclusive results should changing the usage flag to one of the alternatives (__DYNAMIC_DRAW__ or __STREAM_DRAW__) be considered.

기하를 위한 정점들은 응용 프로그램 메모리에서 어느 때나 렌더링하기 위해, 그래픽 메모리에서 이전에 저장된 것을 위해 참조됩니다. 이는 인덱스 버퍼에도 적용됩니다. 좋은 성능을 얻기 위해서, 당신은 DrawArray를 사용하여 응용 프로그램 메모리에서 연속적으로 참조하면 절대 안됩니다. 버퍼 오브젝트는 언제나 기하와 인덱스를 저장하기위해 사용되어야 합니다. DrawArrays를 사용하는 코드가 없는지 확인하고, 버퍼 바인딩 없이 DrawElements를 호출하는 코드가 없는지 확인하세요. 할당 시 버퍼 오브젝트의 디폴트 버퍼 사용 플래그는 __STATIC_DRAW__ 입니다. 

참고 : __STATIC_DRAW__ 는 버퍼에 한번도 쓰지 않을 수 있다는 것을 의미하지 않습니다.(모든 버퍼에 쓰기는 최대한 피해야 함에도 불구하고) 심지어 버퍼의 내용이 모든 몇 프레임에 업데이트 되더라도, __STATIC_DRAW__ 플래그는 적절한 사용 플래그가 될 것입니다. 오직 조심스러운 벤치마킹과 이의 결과를 통한 추론이 고려된 여러 대안 중의 하나로 바꾸어야 합니다.(__DYNAMIC_DRAW__ or __STREAM_DRAW__)

## 기하를 적은 버퍼와 드로우콜로 묶으십시오.(_batch_) (G7)

There are only so many draw calls, or batches of geometry, that can be submitted to GL before the application becomes CPU bound. Each draw call has an overhead that is more or less fixed. Therefore, it is very important to increase the sizes of batches whenever possible. There does not need to be a one-to-one correspondence between a draw call and a buffer—a large vertex buffer can store geometry with a similar layout for multiple models. One or more index buffers can be used to select the subset of vertices needed from the vertex buffer. A common mistake is to have too many small buffers, leading to too many draw calls and thus high CPU load. If the number of draw calls issued in any given frame goes into many hundreds or thousands, then it is time to consider combining similar geometry in fewer buffers and use appropriate offsets when defining the attribute data and creating the index buffer.
Unconnected geometry can be stitched together with degenerate triangles (alternatively, by using extension NV_primitive_restart2 when available). Degenerate triangles are triangles where two or more vertices are coincident leading to a null surface. These are trivially rejected and ignored by the GPU. The benefit from stitching together geometry with degenerate triangles, such that fewer and larger buffers are needed, tends to outweigh the minor overhead of sending degenerates triangles down the pipeline. If geometry batches are being broken up to bind different textures, then look at combining several images into fewer textures (T5).

응용 프로그램이 CPU 바운드에 걸리기 전에는, 오직 GL에 의해 제공된 수많은 드로우콜 혹은 기하의 _batch_ 돌이 있습니다. 각각의 드로우콜은 더 많거나 적게 고정된 오버헤드를 가지고 있습니다. 그러므로 가능한 만큼 _batch_ 들의 크기를 늘리는 것은 굉장히 중요합니다. 버퍼와 드로우콜 사이에 일대일 상관관계는 필요하지 않고―큰 정점 버퍼는 같은 레이아웃의 여러 모델을 저장할 수 있습니다. 하나 혹은 그 이상의 인덱스 버퍼는 정점 버퍼에서 필요한 하위의 정점을 선택하도록 사용합니다. 일반적인 실수는 수많은 작은 버퍼를 가지는 것입니다. 이는 수많은 드로우 콜, 높은 CPU 부하로 이어집니다. 만약 수많은 _drawcall_ 이 주어진 프레임에 주어지고, 그 프레임이 수백,수천만큼 이어진다면, 그때는 비슷한 기하를 몇개의 버퍼로 합치고, 어트리뷰트 데이터에 적절한 오프셋을 사용하고, 인덱스 버퍼를 만들어야 합니다. 연결되지 않은 기하는 _degenerate triangle_ 을 통해 붙여질 수 있습니다.(대안으로, NV_primitive_restart2 를 사용할 수 있습니다.) _degenerate triangle_ 은 두 혹은 더 많은 정점이 없는 표면(_null surface_)에 일치하는 삼각형 입니다.이는 보통 GPU에 의해 거부되거나 무시됩니다. 기하를 _degenerate triangle_ 을 통해 붙이는 것의 장점은, 적은 갯수의 더 큰 버퍼가 필요할 때, _degenerate triangle_ 의 부하를 능가하는 경향이 있기 때문입니다. 만약 기하 _batch_ 들이 다른 텍스쳐를 가지고 있어 부서진다면, 그때는 여러 텍스쳐럴 더 적은 텍스쳐로 합치는 것을 보세요. (T5)

## 인덱스를 위해 가장 적지만 가능한 데이터를 사용하십시오. (G8)

When the geometry uses relatively few vertices, an index buffer should specify vertices using only UNSIGNED_BYTE instead of UNSIGNED_SHORT (or an even larger integer type if the ES2 implementation supports it). Count the number of unique vertices per buffer and choose the right data type. When batching geometry for several unrelated models into fewer buffer objects (G7), then a larger data type for the indices may be required. This is not a concern compared to the larger performance benefits of batching.

기하가 상대적으로 작은 정점들을 사용할 때, 인덱스 버퍼에서 버텍스의 인덱스를 표현할 때 UNSIGNED_SHORT 대신 UNSIGNED_BYTE를 사용하세요.(혹은 ES2 구현이 제공하는 더 큰 정수 타입). 버퍼별 유일한 버텍스를 세고 적절한 데이터 타입을 선택하세요. 여러 관련되지 않은 모델를 위해 적은 버퍼 오브젝트에 있는 기하를 _batch_ 할 때, 더 큰 데이터 타입의 인덱스가 필요할 것 입니다. 이는 _batch_ 로 얻을 더 나은 성능과 비교하면 걱정할 것이 아닙니다.

## 렌더링 루프에서 새로운 버퍼를 할당하는 것을 피하십시오. (G9)

If the application frequently updates the geometry, then allocate a set of sufficiently large buffers when the application initializes. A BufferData call with a NULL data pointer will reserve the amount of memory you specify. This eliminates the time spent waiting for an allocation to complete in the rendering loop. Reusing pre-allocated buffers also helps to reduce memory fragmentation.

만약 응용 프로그램이 자주 기하를 업데이트 한다면, 그때는 충분히 큰 버퍼 세트를 응용 프로그램의 초기화시 할당하세요. null 데이터 포인터와 함께 _BufferData_ 호출은 당신이 명시한 메모리를 예약할 수 있습니다. 이는 렌더링 루프에서 할당을 완료하기 위한 시간을 제거합니다. 미리 할당한 버퍼의 재사용은 메모리 파편화를 줄이는데 도움이 됩니다.

Note: Writing to a buffer object that is being used by the GPU can introduce bubbles in the pipeline where no useful work is being done. To avoid reducing throughput when updating buffers, consider cycling between multiple buffers to minimize the possibility of updating the buffer from which content is currently being rendered.

참고: GPU에서 사용되는 버퍼 오브젝트에 쓰는 것은 파이프라인에 작업을 끝내기에 적절하지 않은 거품을 초래합니다. 버퍼에 업데이트할 때 처리량을 줄이는 것을 피하기 위해, 내용이 렌더링될 때 버퍼를 업데이트 하는 가능성을 최소화 하게 위해 여러 버퍼를 돌려가면서 쓰는 것으로 고려하세요.

## 이전에, 많이 컬링하십시오. (G10)

The GPU will not rasterize primitives when all of its vertices fall outside the viewport. It also avoids processing hidden fragments when the depth test or stencil test fails (P4). However, this does not mean that the GPU should do all the work in deciding what is visible. In the case of vertices, they need to be loaded, assembled and processed in the vertex shader, before the GPU can decide whether to cull or clip parts of the geometry. Testing a single, simple bounding volume that encloses the geometry against the current view frustum on the CPU side is a lot faster than testing hundreds of thousands of vertices on the GPU. If an application is limited by vertex processing, this is definitely the place to begin optimizing. Spheres are the most efficient volumes to test against and the volume of choice if geometry is rotational symmetrical. For some geometry, spheres tend to lead to overly conservative visibility acceptance. A rectangular cuboid (box) is only a slightly more expensive test but can be made to fit more tightly on most geometry. Hierarchical culling can often be employed to reduce the number of tests necessary on the CPU. Efficient and advanced culling algorithms have been heavily researched and published for many years. You can find a good introduction in the survey at the below locations.

 GPU는 _viewport_ 의 바깥으로 모든 정점이 떨어질 때 래스라이즈를 하지 않습니다. 이는 또한 _depth test_ 혹은 _stencil test_ 가(P4) 실패 할때 숨겨진 _fragment_ 를 피합니다. 하지만 이는 GPU가 모든 가시성을 결정하기 위한 일을 한다는 의미는 아닙니다. 정점의 경우, 로딩이 되고, 정점 쉐이더에서 조합과 처리가, GPU가 기하의 일부분을 컬링하거나 클리핑할지 말지 정하기 이전에 됩니다. 간단한 하나의 테스트, 기하를 감싸는 경계 볼륨을 현재 뷰 프러스텀을 CPU에서 비교하는 것은 GPU에서 수천개의 정점을 테스트 하는 것 보다 빠릅니다. 만약에 응용 프로그램이 정점 처리에 한계가 왔다면, 이건 최적화를 시작할 지점이 틀림없습니다. 어떤 기하의 경우, 구가 큰 보수적인 가시성 수락을 이끄는 경향이 있습니다. 직육면체는 오직 조금 더 비싼 테스트이나 대부분의 기하에 잘 맞출 수 있습니다. 위계적 컬링(hierarchical culling)은 CPU에서의 보통 테스트의 숫자를 줄이는데 종종 사용됩니다. 효율적이고 심화된 컬링 알고리즘은 몇년에 이어서 많이 연구되고 출판되었습니다. 아래의 서베이에서 좋은 소개를 볼 수 있습니다.

| Document | URL to Latest |
| ----- | ----- |
| Visibility in Computer Graphics, by Jiří Bittner and Peter Wonka | [URL](http://www.cg.tuwien.ac.at/research/publications/2003/Bittner-2003-VCG/TR-186-2-03-03Paper.pdf) |

# Shader Programs
Writing efficient shaders is critical to achieving good performance. One should treat shaders like pieces of code that run in the inner-most loops on a CPU. There is a very high cost to littering these with conditionals or recomputing loop invariants. Before optimizing an expensive vertex shader, make sure geometry that is entirely outside the view frustum is being culled on the CPU. Before optimizing an expensive fragment shader, make sure the application is not generating an excess number of fragments with it.
Note: When optimizing shaders, any source code that does not contribute to its output variables is optimized out by the compiler. This feature can be exploited to gain knowledge about whether the shader is part of the current bottleneck by multiplying the output variable with a null vector to reduce the workload and then measure if frame rate improves. Conversely, at the final stages of optimization one can quickly measure if there is headroom for increasing workload to offload computations to shader unit or to improve image quality by adding meaningless but expensive ALU instructions, or texture sampling, to the output variables.
## Move computations up the pipeline (P1)
As the rendering pipeline is traversed from the CPU to the vertex processor and then to the fragment processor, the required workload tends to increase a few orders of magnitude each time. Computations constant per model, per primitive or per vertex do not belong in the fragment processor and should be moved up to the vertex processor or earlier. Per draw call computations do not belong in the vertex processor and should be moved to the CPU. For instance, if lighting is done in eye-space, the light vector should be transformed into eye-space and stored in a uniform rather than repeating this for each vertex or, even worse, per fragment. The light vector should naturally be stored pre-normalized. Usually the light vector computations are constant for the draw call, so they do not belong in any shader.
## Do not write large or generalized shaders (P2)
It is critical to resist the temptation to write shader programs that take different code paths depending on whether one or more constant variable have a particular value. Uniforms are intended as constants for one (or hopefully many) primitives—they are not substitutes for calling UseProgram. Shaders should be minimal and specialized to the task they perform. It is much better to have many small shaders that run fast than a few large shaders that all run slow. Code re-use (when source shaders are supported) should be handled at the application level using the ShaderSource function. If the advice here of not writing generalized shaders goes against the conflicting goal of minimizing shader and state changes, smaller and more specialized shaders are generally preferred. Additionally, be careful with writing shader functions intended for concatenation into the final shader source code - shared functions tend to be overly generic and make it harder to exploit possible shortcuts.
## Take advantage of application specific knowledge (P3)
Application specific knowledge can be used to simplify or avoid computations. Math shortcuts should be pursued everywhere because there are optimizations that the shader compiler or the GPU cannot make. For instance, rendering screen-aligned primitives is common for 2D user interface and post-processing effects. In this case, the entire modelview transformation is avoided by defining the vertices in NDC (normalized device coordinates). A full-screen quad has its vertex coordinates in the [-1.0,1.0] range so these can be passed directly from the vertex attribute to gl_Position. The types of matrix transformations applied in the application when creating the modelview matrix should be tracked and exploited when possible. For instance, an orthonormal matrix (e.g. no non-uniform scaling) leads to an opportunity to avoid computations when transforming normals with the inverse-transpose sub-matrix.
## Optimize for depth and stencil culling (P4)
The GPU can quickly reject fragments based on depth or stencil testing before the fragment shader is executed. The depth complexity of a scene is the number of times each fragment gets written. Depth complexity can be measured by incrementing values in a stencil buffer. A high depth complexity in a 3D scene can be a result of rendering opaque objects in a non-optimal order. The worst case is rendering back-to-front (aka painter's algorithm) because it leads to a large number of fragments being overdrawn. An application with high depth complexity should ensure that opaque objects are rendered sorted front-to-back order with depth testing enabled. Straightforward rendering of 2D user interfaces also leads to a high depth complexity that can often be decreased with the same technique but also by using the stencil buffer to mask fragments. Applications that are heavily fragment limited can be sped up significantly with clever use of these techniques—sometimes up to a factor of 10 or more.
If vertex processing is not a bottleneck, it is worthwhile to run experiments that prime the depth buffer in a first pass. Disable all color writes with ColorMask on the first pass. The fragments in the depth buffer can then serve as occluders in a second pass when color writes are enabled and the expensive fragment shaders are executed. Disable depth writes with DepthMask in the second pass since there is no point in writing it twice.
## Do not discard fragments, or modify depth, unless absolutely necessary (P5)
Some operations prevent the hardware from enabling its automatic optimization that rejects fragments early in the pipeline (early-Z). In particular, the discard operation that discards fragments based on some criteria will disable early-Z on some platforms. It is critical to limit the use of discarding as much as possible (e.g., alpha testing)—unless depth writing can be disabled. Another example is found in the GL_NV_fragdepth extension available on some platforms, where the depth value can be written from the fragment shader. This operation also forces the GPU to opt out of Early-Z reject in order to ensure correct rendering.
## Avoid conditionals in shaders when possible (P6)
Fragments are processed in chunks and both branches of a conditional may need to be evaluated before the result of the false branch can be discarded by the GPU. Be careful with assuming that conditionals skip computations and reduce the workload. This warning is particularly relevant to fragment shaders. Benchmarking shaders can determine if conditionals in the vertex or fragment shaders actually end up decreasing the workload. Some conditional code can be rewritten in terms of algebra and/or built-in functions. For instance, the dot product between a normal and a light vector may be negative in which case the result is not needed in a lighting equation. Instead of:
```
if (nDotL > 0.0) ...
```
the value can be clamped with:
```
clamp(nDotL, 0.0, 1.0)
```
and unconditionally used in the result (the negative value results in a zero-product). Clamp may be faster than max and/or min for the 0.0 and 1.0 cases, but as always benchmarking will have the final say in the matter. Another reason to make an effort of avoiding conditionals in fragment shaders is that mipmapped textures return undefined results when executed in a block statement that is conditional on run-time values. Although the GLSL functions texture*Lod can be used to bias or specify the mipmap LOD, it is expensive to manually derive the mipmap LOD. In addition, these LOD biasing samplers may not run as fast as the non-LOD samplers.
## Use appropriate precision qualifiers (P7)
Recall that the default precision in vertex shaders is highp, and that fragment shaders have no default precision until explicitly set. Precision qualifiers can be valuable hints to the compiler to reduce register pressure and may improve performance for several reasons. Low precision may run twice as fast in hardware as high precision. These optimizations can be approached by initially using highp and gradually reducing the precision to lowp until rendering artifacts appear; if it looks good enough, then it is good enough. As a rule of thumb, vertex position, exponential and trigonometry functions need highp. Texture coordinates may need anything from lowp to highp depending on texture width and height. Many application-defined uniform variables, interpolated colors, normals and texture samples can usually be represented using lowp. However, floating-point texture samplers need more than low precision - this is one of several reasons to minimize the use of floating-point textures (T6).
## Use the built-in functions and variable (P8)
The built-ins have a higher chance of compiling optimally and may even be implemented in hardware. For instance, do not write shader code to determine the forward primitive face or compute the reflection vector in terms of dot-products and algebra; instead, use the built-in variable gl_FrontFacing or the built-in function reflect, respectively.
## Consider encoding complex functions in textures (P9)
Shaders normally contain both arithmetic (ALU) and texture operations. A batch of ALU operations may hide the latency of fetching samples from texture because they occur in parallel. If a shader is the primary bottleneck, and when the ALU operations significantly outnumber the texture operations, it is worthwhile to investigate if some of these operations can be encoded in textures. Sub-expressions in shaders can sometimes be stored in LUTs (look-up-tables). LUTs can sometimes be implemented in textures with sufficient precision and accessed as 1D or 2D textures with NEAREST filtering.
Note: The old trick of using cubemaps to normalize vectors is most likely a performance loss on discrete GPUs. If you pursue this idea, then make sure to benchmark to determine if you have improved or worsened the performance!
## Limit the amount of indirect texturing (P10)
Indirect texturing can sometimes be useful, but when the result of a texture operation depends on another texture operation, the latency of texture sampling is difficult to hide. It also tends to lead to scattered reads that minimize the benefit of the texture cache. Indirect texturing can sometimes be reduced, or avoided, at the expense of memory. Whether that trade-off makes sense should of course be analyzed and benchmarked.
## Do not let GLSL syntax obscure math optimizations (P11)
The GLSL shading language conveniently overloads arithmetic operators for vectors and matrices. Care must be taken to not miss optimization opportunities due to this syntax simplification. For instance, a rotation matrix can, but should not, be defined as homogenous 4x4 matrix just because the other operand is a vec4 vector. A generalized rotation matrix should be described only as a 3 x 3 matrix and applied to vec3 vectors. And a rotation around basic vectors can be done even more efficiently than mat3 * vec3 by directly accessing the relevant vector and matrix components with cos and sin. Take advantage of any specific application knowledge to reduce the number of needed scalar instructions.
## Only normalize vectors when it is necessary (P12)
Normalization of vectors is required to efficiently calculate the angle between them, or perhaps more typically, the diffuse component in many commonly used lighting equations. In theory, normalization is required for geometry normals after having transformed them with the normal matrix. In practice, it may not matter depending on the composition of the matrix. It is a common mistake to normalizing vectors where it is not necessary, or at least not visually discernible. As a result, the application may run slower for no good reason. For instance, consider the case of interpolating vertex normals in order to compute lighting per fragment (i.e., Phong shading). If the normal matrix only rotates, there is little reason to normalize the normal vectors before interpolating.
Note: Barycentric interpolation will not preserve the unit length of these vectors. So normals that are interpolated in varying variables do must be normalized to ensure the dot-product with the light vector obeys the cosine emission law.
# Textures
Textures consume the largest amount of the available memory and bandwidth in many applications. One of the best places to look for improvements when short on memory or bandwidth to optimize texture size, format and usage. Careless use of texturing can degrade the frame rate and can even result in inferior image quality.
## Use texture compression whenever possible (T1)
Texture compression brings several benefits that result from textures taking up less memory: compressed textures use less of the available memory bandwidth, reduces download time, and increases the efficiency of the texture cache. The texture_compression_s3tc and texture_compression_latc extensions both provide block-based lossy texture compression that can be decompressed efficiently in hardware. The S3TC extension gives 8:1 or 4:1 compression ratio and is suitable for color images with 3 or 4 channels (with or without alpha) with relatively low-frequency data. Photographs and other images that compress satisfactory with JPEG are great candidates for S3TC. Images with hard and crisp edges are less good candidates for S3TC and may appear slightly blurred and noisy. The LATC extension yields a 2:1 compression ratio, but improves on the quality and can be useful for high resolution normal maps. The third coordinate is derived in the fragment shader—be sure to benchmark if the application can afford this trade-off between memory and computations! Unlike S3TC, the channels in LATC are compressed separately, and quantization is less hard. Using texture compression does not always result in lower perceived image quality, and with these extensions one can experiment with increasing the texture resolution for the same memory. There are off-line tools to compress textures (even if a GL extension supports compressing them on-the-fly). Search the NVIDIA developer website for "Texture Tools".
## Use mipmaps when appropriate (T2)
Mipmaps should be used when there is not an obvious one-to-one mapping between texels and framebuffer pixels. If texture minification occurs in a scene and there are no mipmaps to access, texture cache utilization will be poor due to the sparse sampling. If texture minification occurs more often than not, then the texture size may be too large to begin with. Coloring the mipmap levels differently can provide a visual clue to the amount of minification that is occurring. When reducing the texture size, it may also be worthwhile to perform experiments to see if some degree of magnification is visually acceptable and if it improves frame rate.
Although the GenerateMipmap function is convenient, it should not be the only option for generating a mipmap chain. This function emphasizes execution speed over image quality by using a simple box filter. Generating mipmaps off-line using more advanced filters (e.g. Lanczos/Sinc) will often yield improved image quality at no extra cost. However, GenerateMipmap may be preferable when generating textures dynamically due to speed. One of the only situations where you do not want to use mipmaps is if there is always a one-to-one mapping between texels and pixels. This is sometimes the case in 3D, but more often the case for 2D user interfaces. Recall that a mipmapped texture takes up 33% more storage than un-mipmapped, but they can provide much better performance and even better image quality through reduced aliasing.
## Use the smallest possible textures size (T3)
Always use the smallest possible texture size for any content that gives acceptable image quality. The appropriate size of a texture should be determined by the size of the framebuffer and the way the textured geometry is projected onto it. But even when you have a one-to-one mapping between texels and framebuffer pixels, there may be cases where a smaller size can be used. For instance, when blending a texture on the existing content in the entire framebuffer, the texture does not necessarily have to be the same width and height as the framebuffer. It may be the case that a significantly smaller texture that is magnified will produce results that are good enough. The bandwidth that is saved from using a smaller and more appropriately sized texture can instead be spent where it actually contributes to better image quality or performance.
## Use the smallest possible texture format and data type (T4)
If hardware accelerated texture compression cannot be used for some textures, then consider using a texture format with fewer components and/or fewer bits per component. Textures for user interface elements sometimes have hard edges or color gradients that result in inferior image quality when compressed. The S3TC algorithm make assumptions that changes are smooth and colors values can be quantized. If these assumptions do not fit a particular image, but the number of unique colors is still low, then experiment with storing these in a packed texture format using 16 bit/texel (e.g. UNSIGNED_SHORT_5_6_5). Although the colors are remapped with less accuracy it may not be noticeable in the final application. Grayscale images should be stored as LUMINANCE and tinted images can sometimes be stored the same way with the added cost of a dot product with the tint color. If normal maps do not compress satisfactory with the LATC format, then it may be possible to store two of the normals coordinates in uncompressed LUMINANCE_ALPHA and derive the third in a shader assuming the direction (sign) of the normal is implicit (as is the case of a heightmap terrain).
Note: When optimizing uncompressed textures, the exception case that 24-bit (RGB) textures are not necessarily faster to download or smaller in memory than 32-bit (RGBA) on most GPUs. In this case, it may be possible to use the last component for something useful. For instance, if there already is an 8-bit greyscale texture that is needed at the same time as an opaque color texture, that single component texture can be stored in the unused alpha component of a 32-bit (RGBA). The component could define a specular/reflectance map that describe where and to what degree light is reflected. This is useful for terrain satellite imagery or land cover textures with water/snow/ice areas or for car textures with their metal and glass surfaces or for textures for buildings with glass windows.
## Store multiple images in each texture object (T5)
There is no requirement that there is a one-to-one mapping between an image and a texture object. Textures objects can contain multiple distinct images. These are sometimes referred to as a "texture atlas" or a "texture page". The geometry defines texture coordinates that only reference a subset of the texture. Texture atlases are useful for minimizing state changes and enables larger batches when rendering. For example, residential houses and office buildings and factories might all use distinct texture images. But the geometry and vertex layout for each is most likely identical so these could share the same buffer object. If the distinct images are stored in a texture atlas instead of as separate textures, then these different kinds of buildings can all be rendered more efficiently in the same draw call (G7). The texture object could be a 2D texture, a cubemap texture or an array texture.
Note: Note that if mipmapping is enabled, the sub-textures in an atlas must have a border wide enough to ensure that smaller mipmaps are not generated using texels from neighboring images. And if texture tiling (REPEAT or MIRRORED_REPEAT) is needed for a sub-image then it may be better to store it outside the texture atlas.
Emulating either wrapping mode in a shader by manipulating texture coordinates is possible, but not free. A cubemap texture can sometimes be useful since wrapping and filtering apply per face, but the texture coordinates used must be remapped to a vec3 which may be inconvenient. If all the sub-images have the same or similar size, format and type (e.g. image icons), the images are a good candidate for the array texture extension if supported. Array textures may be more appropriate here than a 2D texture atlas where mipmapping and wrapping restrictions have to be taken into consideration.
## Float textures are always expensive (T6)
Textures with a floating-point format should be avoided whenever possible. If these textures are simply being used to represent a larger range of values, it may be possible to replace these with fixed point textures and scaling instructions. For instance, unsigned 16-bit integers cannot even accurately be represented by half-precision floats (FP16). These would have to be stored using single precision (FP32) leading to twice the memory and bandwidth requirements. It might be better to store these values in two components using 8 bits (LA8) and spend ALU instructions to unpack them in a shader.
Note: Floating-point textures may not support anything better than nearest filtering.
## Prefer power-of-two (POT) textures in most cases (T7)
Although Non-Power-of-Two (NPOT) textures are supported in ES2 they come with a CLAMP_TO_EDGE restriction on the wrapping mode (unless relaxed by an extension). More importantly, they cannot be mipmapped (unless relaxed by an extension). For that reason, POT textures should be used when there is not significant memory and bandwidth to be saved from using NPOT. However, an NPOT texture may be padded internally to accommodate alignment restrictions in hardware and that the amount of memory saved might not be quite as large as the width and height suggests. As a rule of thumb, only large (i.e., hundreds of texels) NPOT textures will effectively save a significant amount of memory over POT textures.
## Update textures sparingly (T8)
Writing to GPU resources can be expensive—it applies to textures as well. If texture updates are required, then determine if they really need to be updated per frame or if the same texture can be reused for several frames. For environment maps, unless the lighting or the objects in the environment have been transformed (e.g., moved/rotated) sufficiently to invalidate the previous map, the visual difference may not be noticeable but the performance improvement can be. The same applies to the depth texture(s) used for shadow mapping algorithms.
## Update textures efficiently (T9)
When updating an existing texture, use TexSubImage instead of re-defining its entire contents with TexImage when possible.
Note: When using TexSubImage it is important to specify the same texture format and data type with which that the texture object was defined; otherwise, there may be an expensive conversion as texels are being updated.
If the application is only updating from a sub-rectangle of pixels in client memory, then remember that the driver has no knowledge about the stride of pixels in your image. When the width of the image rectangle differs from the texture width, this normally requires a loop through single pixel rows calling TexSubImage repeatedly while updating the client memory offsets with pointer arithmetic. In this case, the unpack_subimage extension can be used (if supported) to set the UNPACK_ROW_LENGTH pixelstore parameter to update the entire region with one TexSubImage call.
If the application is only updating from a sub-rectangle of pixels in client memory, then remember that the driver has no knowledge about the stride of pixels in your image. When the width of the image rectangle differs from the texture width, this normally requires a loop through single pixel rows calling TexSubImage repeatedly while updating the client memory offsets with pointer arithmetic. In this case, the unpack_subimage extension can be used (if supported) to set the UNPACK_ROW_LENGTH pixelstore parameter to update the entire region with one TexSubImage call.
## Partition rendering based on alpha blending/testing (T10)
It is sometimes possible to improve performance by splitting up the rendering based on whether alpha blending or alpha testing is required. Use separate draw calls for opaque geometry so these can be rendered with maximum efficiency with blending disabled. Perform other draw calls for transparent geometry with alpha blending enabled, taking into account the draw ordering that transparent geometry requires. As always, benchmarks should be run to determine if this improves or reduces the frame rate since you will be batching less by splitting up draw calls.
## Filter textures appropriately (T11)
Do not automatically set expensive texture filters and enable anisotropic filtering. Remember that nearest-neighbor filtering always fetches one texel, bilinear filtering fetches up to four texels and trilinear fetches up to eight texels. However, it can be incorrect to draw assumptions about the performance cost based on this. Bilinear filtering may not cost four times as much as nearest filtering, and trilinear can be more or less than twice as expensive as bilinear. Even though textures have mipmaps, it does not automatically mean trilinear filtering should be used. That decision should be made entirely from observing the images from the running application. Only then can a judgment be made if any abrupt changes between mipmap levels are visually disturbing enough to justify the cost of interpolating the mipmaps with trilinear filtering. The same applies to anisotropic filtering, which is significantly more expensive and bandwidth intensive than bilinear or trilinear filtering. If the angle between the textured primitives and the projection plane (e.g. near plane) is never very large, there is nothing to be gained from sampling anisotrophically and there is potentially lower performance. Therefore, an application should start off with the simplest possible texture filtering and only enable more expensive filtering after users have inspected the output images. It might be worthwhile to benchmark the changes and take notes along the way. This will provide a better indication of the relative cost of filtering method and if concessions must be made if the performance budget is exceeded.
## Try to exploit texture tiling (T12)
It is common for images to contain the same repeated pattern of pixels. Or an image might repeat a few patterns that are close enough in similarity that they could be replaced with a single pattern without impacting image quality. Tiling textures saves on memory and bandwidth. Some image processing applications can identify repeated patterns and can crop them so they can be tiled infinitely without seams when using textures with the REPEAT wrap mode. Sometimes even a quarter of a tile or shingle may be sufficient to store while using MIRRORED_REPEAT. Consider if tiling variation can be restored or achieved with multi-texturing, using for instance a less expensive grey-scale texture that repeats at a different frequency to modulate the texels from the tiled texture.
## Use framebuffer objects (FBO) for dynamically generated textures (T13)
OpenGL ES comes with functions for copying previously rendered pixels from a framebuffer into a texture (TexCopyImage, TexCopySubImage). These functions should be avoided whenever possible for performance reasons. It is better to bind a framebuffer object with a texture attachment and render directly to the texture. Make sure you check for framebuffer completeness.
Note: Not all pixel formats are color-renderable. Formats with 3 or 4 components in 16 or 32 bits are color-renderable in OpenGL ES 2.0, but LUMINANCE and/or ALPHA may require a fall-back to TexCopyImage functions.
# Miscellaneous
This topic contains miscellaneous OpenGL ES programming tips.
## Avoid reading back the framebuffer contents (M1)
Reading back the framebuffer flushes the GL pipeline and limits the amount CPU/GPU parallelism. Reading frequently or in the middle of a frame stalls the GPU and limits the throughput with lower frame rate as a result. If the buffer contents must be read back (perhaps for picking 3D objects in a complex scene), it should be done minimally and scheduled at the beginning of the next frame. In the special case that the application is reading back into a sub-rectangle of pixels in client memory, the pack_subimage extension (if supported) is very useful. Setting the PACK_ROW_LENGTH pixel store parameter will reduce the loop overhead that will otherwise be necessary (T9).
## Avoid clearing buffers needlessly (M2)
If the application always covers the entire color buffer for each frame, then bandwidth can be saved by not clearing it. It is a common mistake to call Clear(GL_COLOR_BUFFER_BIT) when it is not necessary. If only part of the color buffer is modified, then constrain pixel operations to that region by enabling scissor testing and define a minimal scissor box for the region. The same applies to depth and stencil buffers if full screen testing is not needed.
## Disable blending when it is not needed (M3)
Most blending operations require a read and a write to the framebuffer.
Note: Memory bandwidth is often doubled when rendering with blending is enabled. The number of blended fragments should be kept to a minimum—it can drastically speed up the GL application.
## Minimize memory fragmentation (M4)
Buffer objects and glTexImage* functions are effectively graphics memory allocations. Reusing existing buffer objects and texture objects will reduce memory fragmentation. If geometry or textures are generated dynamically, the application should allocate a minimal pool of objects for this purpose during application initialization. It may be that two buffers or textures used in a round-robin fashion are optimal for reducing the risk that the GPU is waiting on the resource. Also, recall that sampling a texture that is being rendered to, at the same time, is undefined. This can be another reason to alternate between objects. For more information, see Memory Fragmentation in this appendix.
Avoiding Memory Fragmentation
Memory Fragmentation generally is a bad thing. This is especially true for computer graphics applications. In addition to avoiding system memory fragmentation, a graphics application should strive to avoid video memory fragmentation as well.
Fortunately, controlling video memory fragmentation has techniques very similar to those used to avoid system memory fragmentation. Since system memory fragmentation control is fairly well known, this document will only treat system memory issues in passing and focuses on video memory techniques.
# Optimizing OpenGL ES Applications
Optimization is an iterative process. It can be time consuming, especially without prior experience determining where bottlenecks tend to occur. Effort should be directed towards the critical areas instead of starting a random place in the rendering code. When the graphics application is complex it may be difficult to know where to start or exactly where optimizations will yield the best return.
## Partition the analysis into manageable chunks
Many rendering applications are complex and consist of hundreds of objects. But usually they consist of logically separate rendering code. For example, a rendered image may consist of roads, buildings, landmarks, points of interest, sky, clouds, buildings, water, terrain, icons, and a 2D user interface. It is helpful to write the GL application such that rendering of each type of object can be disabled easily. This allows easy identification of the most expensive objects when benchmarking and therefore makes optimizing the rendering code more manageable.
## Become familiar with bottlenecks in the graphics pipeline
It is important to begin optimizations by identifying the performance bottlenecks at the different stages in the graphics pipeline. Because the work introduced in the beginning of the pipeline normally affects the work needed at later stages, it often makes sense to work backwards from the end of the pipeline. An introduction to identifying graphics bottlenecks can be found in the GPU Gems book, "Chapter 28. Graphics Pipeline Performance" (Cem Cebenoyan, NVIDIA).
# Avoiding Memory Fragmentation
Memory Fragmentation generally is a bad thing. This is especially true for computer graphics applications. In addition to avoiding system memory fragmentation, a graphics application should strive to avoid video memory fragmentation as well.
Fortunately, controlling video memory fragmentation has techniques very similar to those used to avoid system memory fragmentation. Since system memory fragmentation control is fairly well known, this document will only treat system memory issues in passing and focuses on video memory techniques.
# Video Memory Overview
Video memory is much more heterogenous than system memory.
NVIDIA video memory allocation algorithms have to take the following into account:
- There are multiple types of video memory types. The number and names of the types vary by GPU model, but GPUs generally have at least two; linear, which is essentially unformatted, and one or more GPU specific types. The GPU tracks different types of memory, and will access and write them differently. The types are important because GPU native types can be faster for a given set of operations; in some GPU architectures, the difference is small, on the order of 10-15%. On others, it can be quite large, more than 100% faster than linear memory.
- Video memory is often banked, especially for mipmapped textures. In most architecture, alternating mipmap levels for a given texture must be put in separate banks. This separation is mandatory in most NVIDIA GPUs.
- In addition to the restrictions above, different memory regions have different alignment restrictions, to match host pages, improve DMA performance, or speed up framebuffer scan out. These alignment requirements may be orthogonal to the memory types, adding further complication.
- The allocator may have other special restrictions that enhance performance, such as distributing allocations to a sequence of different banks to improve allocation speed.
- These extra constraints complicate the video memory allocator, and make allocations much more sensitive to reductions in available video memory. This is the major reason why NVIDIA does not support multiple independent heaps in video memory, instead requiring the application to allocate in such a way as to minimize fragmentation.

# Allocating and Freeing Video Memory

This topic describes considerations for allocating and freeing video memory.

## Allocating buffers

When using OpenGL ES/EGL, there is only a small set of APIs that actually lead to long-term video memory buffer allocation:
```
glBufferData(enum target, sizeiptr size, const void *data, enum usage)
 
glTexImage2D(enum target, int level, int internalFormat, sizei width, sizei height, int border, enum format, enum type, const void *pixels)
 
glCopyTexImage2D(enum target, int level, enum internalformat, int x, int y, sizei width, sizei height, int border)
```
Note: The glCopyTexImage2D function allocates only when it copies to a null.
```
eglCreateWindowSurface(EGLDisplay dpy, EGLConfig config, NativeWindowType win, const EGLint *attrib_list)
 
eglCreatePbufferSurface(EGLDisplay dpy, EGLConfig config, const EGLint *attrib_list)
 
eglCreatePixmapSurface(EGLDisplay dpy, EGLConfig config, NativePixmapType pixmap, const EGLint *attrib_list)
```
## Freeing buffers
A similar set of APIs free allocated video memory buffers, whether they are textures, VBOs, or surfaces:

```
glDeleteBuffers(sizei n, uint *buffers)
 
glDeleteTextures(sizei n const uint *textures)
 
eglDestroySurface(EGLDisplay dpy, EGLSurface surface)
```
Note: The glDeleteTextures function works only if the texture object is greater than zero; the default texture can't be explicitly deleted (although it can be replaced with a texture containing one or two dimensions of zero, which accomplishes the same thing).
Conceptually, these calls can be thought of as malloc() and free() for VBOs and texture maps, respectively. The same techniques for avoiding fragmentation can also be applied.
## Updating a Subregion of a Buffer
In many cases, avoiding fragmentation means placing multiple objects into the same shared buffer, or reusing a buffer by deleting or overwriting an older object with a newer one. OpenGL ES provides a method for updating an arbitrary section of allocated VBOs, textures, and surfaces:
```
glBufferSubData(enum target, intptr offset, sizeiptr size, const void *data, enum usage)
 
glTexSubImage2D(enum target, int level, int xoffset, int yoffset, sizei width, sizei height, enum format, enum type, const void *pixels)
 
glCopyTexSubImage2D(enum target, int level, int xoffset, int yoffset, int x, int y, sizei width, sizei height)
 
glScissor(int left, int bottom, sizei width, sizei height);
 
glViewport(int x, int y, sizei w, sizei h)
```
The glTexSubImage2D and glCopyTexSubImage2D function update a subregion of the target texture image. In the first case, the source comes from an application buffer; in the second, from a rendering surface.
The glScissor and glViewport functions limit rendering to a subregion of a rendering surface. The first specifies the region of the buffer that the glClear function will affect; the second updates the transforms to limit rendered OpenGL ES primitives to the specified subregion.
## Using a Buffer Subregion
Completing the functionality needed to reuse allocated buffers is the ability to use an arbitrary subregion of a texture, VBO, or surface:
```
glDrawArrays(enum mode, int first, sizei count)
 
glReadPixels(int x, int y, sizei width, sizei height, enum format, enum type, void *data)
 
glCopyTexImage2D(enum target, int level, int x, int y, sizei width, sizei height)
 
glCopyTexSubImage2D(enum target, int level, int xoffset, int yoffset, int x, int y, sizei width, sizei height)
```

For VBOs, the glDrawArrays function allows the application to choose a contiguous subset of a VBO.
For textures, there's no explicit call to limit texturing source to a particular subregion. But texture coordinates and wrapping modes can be specified in order to render an arbitrary subregion of texture object.
For surfaces, the glReadPixels function can be used to read from a subregion of a display, when copying data back to an application-allocated buffer.
The glCopyTexImage2D and glCopyTexSubImage2D functions also restrict themselves to copying from a subregion of the display surface when transferring data to a texture map. The only area that's problematic is controlling the direct display of window surface back buffer. OpenGL ES and EGL have no way to show only a subregion of the backbuffer surface, but the native windowing systems may have this functionality.
# Best Practices for Video Memory Management
The following is a list of good practices when allocating video memory to avoid or minimize fragmentation:
## 1. Allocate large buffers early
Ideally allocate large buffers at the start of the program. On average, allocating large surfaces gets more difficult as more allocations occur. When more allocations occur, free space is broken into smaller pieces.
## 2. Combine many small allocations into a smaller number of larger allocations
Small allocations can disproportionately reduce available free space. Not only does the allocator have a fixed overhead per allocation, regardless of size, but small allocations tend to break up large areas of free space into smaller pieces.
The ability to load a subregion of a VBO or texture map, and the ability to render that subregion independently, makes it possible to combine VBOs and textures together. For textures, a large texture can be used to hold a grid of smaller images. For VBOs, multiple vertex arrays can be combined end to end into a larger one. Besides reducing fragmentation, combining related images into a single texture, and related vertex arrays into a single VBO often improves rendering time, since it reduces the number of glBindBuffer or glBindTexture calls required to render a set of related objects.
## 3. Reduce the variation in size of allocated buffers ideally to a single size
Allocating buffers of varying sizes, especially sizes that aren't small multiples of each other, is disruptive of memory space and causes fragmentation. The ability to load and render a subset of a VBO or texture means that data loaded doesn't have to match the size of the allocated buffer; as long as it's smaller, it will work.
This approach does waste space, in that some of the allocated buffer isn't used, but this waste is often offset by the saving in reduced fragmentation and fixed allocation overhead. This approach can often be combined with approach (2) (combining multiple objects into one allocated buffer) to reduce total wastage. Generally, it's safe to ignore wastage it it's a small percentage of the allocated buffer size (say < 5%).
This approach is particularly good for dynamically allocated data, since fixed size blocks can often be freed and reallocated with little or no fragmentation. If wastage is excessive, a set of buffer sizes can be chosen (often a consecutive set of power of two sizes), and the smallest free buffer that will contain the data is used.
## 4. Reuse, rather than free and reallocate, buffers whenever possible
The ability to reload a previously allocated buffer with new data for both VBOs and textures makes this technique practical. Reuse is particularly important for large buffers; it is often better to create a large buffer at program start, and reuse it during mode switches, etc., even if it requires allocating a larger buffer to handle all possible cases.
## 5. Minimize dynamic allocation
If possible, take memory allocation and freeing out of the inner loop of your application. The ability to reuse buffers makes this practical, even for algorithms that require dynamic allocation. Even with reuse, however, it's still better to organize the code to minimize allocations and frees, and to move the remaining ones out of the main code path as much as possible.
## 6. Try to group dynamic allocations
If dynamic allocation is mandatory, try to group similar allocations and frees together. Ideally, an allocation of a buffer is followed by freeing it before another allocation happens. This rarely can be done in practice, but combining a group of related allocations is often nearly as effective.
Again, allocations and frees should be replaced whenever possible. Grouping them is a last resort.
# Graphics Driver CPU Usage
In some cases, the reported graphics driver CPU usage may be high, but in fact the yield is related to other CPUs. To reduce the reported CPU usage, set the environment variable as follows:
```
$ export __GL_YIELD=USLEEP

```
# Performance Guidelines
The NVIDIA Tegra system on a chip (SOC) includes an extremely powerful and flexible 3D GPU whose power is well matched to the OpenGL ES APIs. For basic guidelines and tips on optimal content rendering, see [OpenGL ES Performance for the Tegra Series Guidelines.](https://docs.nvidia.com/drive/drive_os_5.1.6.1L/nvvib_docs/DRIVE_OS_Linux_SDK_Development_Guide/baggage/tegra_gles2_performance.pdf)

## 참조

- [docs.nvidia : OpenGL ES Programming Tips](https://docs.nvidia.com/drive/drive_os_5.1.6.1L/nvvib_docs/index.html#page/DRIVE_OS_Linux_SDK_Development_Guide/Graphics/graphics_opengl.html)

