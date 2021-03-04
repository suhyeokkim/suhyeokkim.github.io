---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - cpp
  - unmanaged_language
  - memory_management
  - game_programming
---

 C++ 에서 메모리 관리는 중요한 문제다. _garbage collector_ 를 지원하는 현대의 많은 언어들과 달리 C++은 OS에서 제공하는 시스템콜을 사용하여 메모리를 직접 할당 받고 반환한다. 하지만 메모리 할당/해제 시스템콜은 가상 페이지 로드 및 병합 비용이 큰 편이고, 성능에 민감한 프로그래머들은 이를 줄이기 위해 고민의 벽에 부딫친다. 이를 개선시키기 위해 많은 사람들이 방법을 고민했다. 그 중에서 필자가 일반적으로 사용하는 방법은 영구/가변 메모리 영역 처럼 단계를 나누어 가상 메모리 페이지 크기 이상의 단위로 할당받아 각각의 뭉텅이에서 공간을 나눠쓰는 방법이다.

 그렇지만 단순히 할당자를 구현하는 것만으로 끝날 문제는 아니다. 직접 컨테이너를 구현하면 입맛에 맞게 쓸 수 있겠지만 여러 비용이 허락해야 가능하고, 사용자 정의 할당자를 지원하는 표준 STL은 여러 제약사항이 존재하기에 쉽지 않다. 하지만 표준 STL과 비슷하게 게임 응용 프로그램을 위해 표준 STL을 개량한 EASTL이라는 대체제를 통해 원하는 메모리 할당자 기능을 쉽게 구현할 수 있었다. 이 글에서는  EASTL에서의 커스텀 메모리 할당자 및 이의 장단점을 서술한다. 해당 포스팅은 EASTL 3.17.06을 기준으로 작성되었다.

<!-- more -->

 누군가의 프로젝트에 EASTL을 처음부터 적용하기 위해선 추가적인 세팅이 몇가지 필요하다. 기본적인 세팅 방법은 다음과 같다.

  1. EASTL은 cmake로 프로젝트 파일을 생성해준다. 즉 cmake가 설치되어야 한다.
  2. [깃헙 레포지토리](https://github.com/electronicarts/EASTL)에서 소스를 가져온다.
  3. 해당 경로에 가서 _cmake ./_ 를 커맨드라인에서 실행해주면 OS와 프로그램에 맞게 파일을 생성해준다. (conan, vcpkg 를 사용해서도 설치 가능하다고 한다.)
  4. cmake가 만든 프로젝트 파일을 통해 정적 라이브러리 파일을 생성한다.
  5. 라이브러리와 인클루드 헤더를 프로젝트에 적용시킨다.

 여기까지는 플랫폼 별로, 사용하는 프로그램 별로 전부 다를 수 있다. 그러니 각자의 상황에 맞게 세팅해야 한다. 
 
 문제는 이대로 사용할 수 없다는 점이다. 링크 에러가 나기 때문이다. 이는 EASTL에서 오버로딩한 new 연산자를 내부에서 참조하고, EASTL 내부에는 참조할 new 연산자가 없기 때문이다. 아래에 명시된 두 new 연산자를 정의해주어야 실행을 위한 프로그램을 빌드할 수 있다. 함수안의 메모리 할당에서 유의할 점은 정렬된 메모리를 항상 할당 해주어야 한다. 아닌 경우에도 최소한의 정렬을 정의해 놓은 _EASTL_ALLOCATOR_MIN_ALIGNMENT_ 을 사용하여 정렬된 메모리 할당이 필요하다. 아래 소스에서는 정렬된 메모리를 할당하는 vc 기반의 코드를 볼 수 있다.

```cpp

void* operator new[](size_t size, const char* pName, int flags, unsigned debugFlags, const char* file, int line)
{
  return _aligned_offset_malloc(size, EASTL_ALLOCATOR_MIN_ALIGNMENT, 0);
}

void* operator new[](size_t size, size_t alignment, size_t alignmentOffset, const char* pName, int flags, unsigned debugFlags, const char* file, int line)
{
  return _aligned_offset_malloc(size, alignment, alignmentOffset);
}

```

 여기까지 실행하고 빌드한다면 동작은 된다. 이제 EASTL에서 제공하는 컨테이너를 돌려보며 확인해볼 수 있다. 
 
``` cpp

... 
{
    eastl::vector<FbxNode*> nodeVector();
    nodeVector.push_back(fbxScene->GetRootNode());
    ...
}

```
 
 여기까지 왔다면 기본적인 세팅은 끝났다. 이제 사용자 지정 할당자를 어떻게 구현했는지 소개해보겠다. 
 
 필자가 원하는 방식대로 구현하기 위해선 사용자 지정 메모리 할당자를 구현해야 했다. 자세한 구현은 아래에서 볼 수 있다.

```cpp

class EASTLAllocator
{
public:
	EASTLAllocator(const char* name = nullptr) : name(nullptr)
	{
		if (name)
		{
			size_t len = strlen(name);
			this->name = (char*)::new(nullptr, __FILE__, __LINE__) char[sizeof(char) * (len + 1)];
			strcpy_s(this->name, len + 1, name);
		}
	}
	EASTLAllocator(const EASTLAllocator& o) : name(nullptr)
	{
		if (o.name)
		{
			size_t len = strlen(o.name);
			name = (char*)::new(nullptr, __FILE__, __LINE__) char[sizeof(char) * (len + 1)];
			strcpy_s(name, len + 1, o.name);
		}
	}
	EASTLAllocator(EASTLAllocator&& o) : name(o.name) { }

	EASTLAllocator& operator=(const EASTLAllocator& o)
	{
		size_t len = strlen(o.name);
		name = (char*)::new(nullptr, __FILE__, __LINE__) char[sizeof(char) * (len + 1)];
		strcpy_s(name, len + 1, o.name);
		return *this;
	}
	EASTLAllocator& operator=(EASTLAllocator&& o)
	{
		name = o.name;
		return *this;
	}

	void* allocate(size_t num_bytes, int flags = 0)
	{
		void* p = ::new(name, __FILE__, __LINE__) char[num_bytes];
		return p;
	}

	void* allocate(size_t num_bytes, size_t alignment, size_t offset, int flags = 0)
	{
		void* p = ::new(alignment, offset, name, __FILE__, __LINE__) char[num_bytes];
		return p;
	}

	void deallocate(void* p, size_t num_bytes)
	{
		::operator delete[] (p, name, __FILE__, __LINE__);
	}

	const char* get_name() const { return name; }
	void set_name(char* n) { name = n; }

protected:
	char* name;

};

bool operator==(const EASTLAllocator& a, const EASTLAllocator& b);
bool operator!=(const EASTLAllocator& a, const EASTLAllocator& b);
```

 위의 EASTLAllocator는 단순하게 오버로딩한 new/delete를 감싼 구현으로, 중요한 점은 할당될 영역의 이름을 통하여 영역을 선택한다는 것과 EASTL에서 allocate/deallocate로 메모리 할당/해제를 한다는 점이다. 
 처음 보는 사람의 입장에서 의문이 들만한 부분은, delete 또한 오버로딩하여 사용한다는 점이다. 이유는 아래와 같다.

 - 논리적으로 new/delete는 한 쌍이어서 이를 구현하는게 직관적이다.
 - 컨테이너가 아닌 경우에도 new/delete를 사용하여 원하는 방식의 메모리 할당이 가능하다.
 - (필자의 특수한 케이스)작업 당시 이동 생성자는 작동하지 않고 복사 생성자만 작동했다. 그래서 할당자 클래스에서의 구현에서 연산자 오버로딩으로 일반화 했다.
 
 이렇게 구현한 할당자를 바탕으로, 표준 STL에서 사용하든 템플릿 선언을 통해 사용하면 된다. 방법은 아래와 같다.

``` cpp

#define EASTL_TEMPARARY_NAME "temp"
... 
{
    eastl::vector<FbxNode*, EASTLAllocator> nodeVector(EASTL_TEMPARARY_NAME);
    nodeVector.push_back(fbxScene->GetRootNode());
    ...
}

```

위의 소스에서 표준 STL과 사용 방법이 다른 점은 컨테이너의 생성자에 할당자를 식별하기 위한 문자열을 넣는다는 점이다. 이를 통해 컨테이너는 추가적인 메모리 할당이 필요할 시 오버로딩된 new/delete 함수를 호출하여 할당을 받으려 할 것이다. 필자가 구현한 new/delete 는 [RenderFromScratch: allocators.cpp](https://github.com/suhyeokkim/RenderFromScratch/blob/master/Framework/source/allocators.cpp) 에서 볼 수 있다.

소개한 커스텀 할당자의 구현 이외에도 EASTL은 SSE 지원을 위한 메모리 정렬을 구현하게 만들고, 고정된 크기의 컨테이너와 컨테이너에서 하나의 노드를 사용자가 직접 정의할 수 있는 instrutive 컨테이너도 지원하고, 이외에도 게임 프로그램에서 필요한 세심한 경우들을 처리해 놓았고, 여러 플랫폼(콘솔, PC 등)에서 테스트가 되었다고 한다. 만약 자신이 게임을 밑바닥부터 구현하고, STL의 사용법을 조금이라도 안다면 EASTL을 사용하는 것도 좋은 방법이라고 생각된다.

## 참조

- [github : EASTL](https://github.com/electronicarts/EASTL)
- [EASTL docsforge](https://eastl.docsforge.com/)
- [open-std : EASTL](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2007/n2271.html)
- [C++ - EASTL](https://jacking75.github.io/Cpp_EASTL/)
- [EASTL - 할당자(allocator)](http://ohyecloudy.com/pnotes/archives/250/)

