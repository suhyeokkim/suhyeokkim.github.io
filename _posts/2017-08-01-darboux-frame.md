---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - math
  - study
---

여러 공간 법선 벡터(_tangent space normal_, _object space normal_)에 대하여 알아보던 도중 모르는 것이 하나있어 정리해볼겸 포스팅해보려 한다. _darboux frame_ 이라는 놈이다.

<!-- more -->

우선 _tangent space normal_ 과 _object space normal_ 에 대해서 설명해야 한다. 그래픽스에서는 빛을 표현하기 위해 노말벡터를 사용한다. 처음에 나온식은 매우 간단하다.

> (빛의 방향 벡터) * (노말 벡터) = (빛이 표현하는 색의 범위(-1~1))

위의 벡터곱은 내적을 뜻한다. 이 식의 결과값은 반사광을 표현하는데 쓰인다. 일반적으로 말하는 _Specular_ 를 뜻한다. 하여튼 빛을 표현하는 것은 그래픽스에서는 굉장히 중요한 일이기 때문에 이 노말벡터를 어떻게 관리하는지가 엄청나게 중요하다. 그래서 여러 방법이 있는데 제일 많이 쓰이는건 _tangent space normal_ 이다. 그런데 _object space normal_ 은 갑자기 왜 튀어나왔느냐? 이유는 간단하다. 두개가 가장 비교가 많이 되는 방법이기 때문이다. _object space normal_ 은 굉장히 간단하다. 저장된 메시 데이터의 노말 벡터값이다. 기본 단위가 저장된 한 개체의 메시의 노말이기 때문에 _object spoce_ 라는 접두사가 붙은 것이다. 그래서 그런지 아래 그림에서 나오는 _object spoce normal_ 이 저장된 텍스쳐는 색이 굉장히 다양하다. 하지만 옆에 _tangent space normal_ 이 저장된 텍스쳐는 색이 거의 일정하다. 왜 그럴까? 우선 앞의 _object space normal_ 은 그냥 오브젝트 기준의 좌표계에서의 정점별 노말값을 저장한 데이터다. 하지만 _tangent space normal_ 은 모델에서 추출한 _tangent_ 값을 통해 _normal_ 값을 구하는 방법이다. [normal tangent binormal]({{ site.baseurl }}{% post_url 2017-07-30-normal-tangent-binormal %}) 에서 설명했었다.

![tangent-space vs objcet-space](https://raw.githubusercontent.com/ssloy/tinyrenderer/gh-pages/img/06b-tangent-space/nm_textures.jpg)

그런데 _tangent space normal_ 에서의 _tangent_ 가 뜻하는 것은 표면의 접선 값이다. 이렇게 표면을 기준으로 하는 것을 [_darboux frame_](https://en.wikipedia.org/wiki/Darboux_frame) 이라고 한다. 프랑스 사람의 이름이라 한글로 읽으면 _다르부-프레임_ 이다. 위키에서는 _"프레네-세레 프레임"_ 이 표면 기하학에서 적용된 것이라 한다. 그만큼 대부분의 정의들이 _"프레네-세레 프레임"_ 과 매우 비슷하다. 다른 점은 곡선에서 표면으로 확장시켰다는 점이다.

## 참조

 - [Github : tinyrenderer Wiki - tangent-space-normal-mapping](https://github.com/ssloy/tinyrenderer/wiki/Lesson-6bis:-tangent-space-normal-mapping)
 - [Wikipedia : darvoux frame](https://en.wikipedia.org/wiki/Darboux_frame)
