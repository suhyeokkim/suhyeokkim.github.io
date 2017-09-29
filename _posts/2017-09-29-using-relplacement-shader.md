---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - render
---

Unity 는 _Replacement Shader_ 라는 렌더링 기능을 지원한다. 이는 Unity 가 Rendering 기능에서 지원하는 약간 Hack 한 테크닉이며 이 기능을 잘 사용하면 쉐이더를 바꿔치기 해서 재미있는 것들을 할 수 있다. _Replacement Shader_ 는 렌더링할 MeshRenderer 들이 가지고 있는 __Material__ 의 Shader 를 사용자가 원하는 것으로 바꾸는 기능이다. 이 기능을 통해 그림자 같은 여러 부가적인 처리를 할 수 있다.

사용하는 방법은 아래와 같다.

```C#
Shader shader = Shader.Find("CustomShaderName");
string replacementTag = "replace";

// tag is optional. if dont need tag, insert null.
camera.RenderWithShader(shader, replacementTag);
```

위의 간단한 예제는 _Replacement Shader_ 를 사용해 한번 그려주는 예제다. 단순히 _Camera.RenderWithShader_ 를 사용하기 때문에 직접 값을 컨트롤할 때 사용하기 좋다. _Replacement Shader_ 를 영구적으로 세팅하여 자동으로 그려주면 아래와 같이 하면된다.

```C#
Shader shader = Shader.Find("CustomShaderName");
string replacementTag = "replace";

// tag is optional. if dont need tag, insert null.
camera.SetReplacementShader(shader, replacementTag);
```

사용 방법은 굉장히 단순하다. 다만 이 _Replacement Shader_ 기능에서 중요한 것은 쉐이더를 단순히 치환하는 것만 포인트가 아니다. 치환된 쉐이더들은 기존 __Material__ 이 가지고 있던 데이터들과 쉐이더 코드에서 이름만 똑같이 맞추어주면 자동으로 데이터들이 쉐이더로 들어온다. 즉 쉐이더를 갈아치우지 않고도 데이터를 공유할 수 있는 것이다. 이는 Unity 의 렌더링에서 굉장히 강력한 시스템으로 초기에는 이해하기도 힘들고 잔머리가 필요하지만 이를 잘 사용만 한다면 굉장히 유용하게 쓰일 수 있다.

필자는 Github 에서 OIT 예제를 보면서 처음 보았다. [Github : OIT_Lab](https://github.com/candycat1992/OIT_Lab) 에서 OIT 를 처리하는 코드에서 구경할 수 있다. 또한 일본 Unity 지사에서 일하는 유명한 keijiro 의 [Skinner](https://github.com/keijiro/Skinner) 에서 위치를 처리하는데 쓰이기도 한다.

# 참조 자료

 - [Unity Reference : Replaced Shaders 에서의 렌더링](https://docs.unity3d.com/kr/current/Manual/SL-ShaderReplacement.html)
