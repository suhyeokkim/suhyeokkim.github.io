---
layout: post
categories: edu,ue4
author: "Su-hyeok Kim"
comments: true
show: false
tag: [edu, ue4]
---

 이 글은 언리얼 엔진 4 교육을 위한 글입니다.

## 강의 환경

### 강의 자료

 - [http://hrmrzizon.github.io][myblog]
 - [언리얼 엔진 4 웹 문서][ue4-doc]
 - [언리얼 엔진 4 에서 지원하는 예제들][ue4-sample]

### 추천 하드웨어 사양

| OS              | CPU                   | Ram           | 여유 디스크 공간 |
| :----------------:    | :-----------------------:           | :------------------:  | :----------------: |
| windows 7,8,10  | Intell 혹은 AMD, 쿼드 코어, 2.5GHz 이상 | 8GB 이상       | 100GB 이상 |


 사양 확인하기 : [CPU-Z 다운로드 페이지][cpuz-down]

### 소프트웨어 설치

우선 [언리얼 엔진 4 공식 홈페이지][ue4-offical]에 접속해 전용 런쳐를 다운로드 합니다. 홈페이지 우측 상단에 링크가 있습니다. 런처 설치는 오래 걸리지 않습니다.

런처 설치가 끝나면 엔진을 설치할 수 있습니다. __그런데 주의할 사항이 있습니다.__ 엔진과 앞으로의 엔진 사용은 꽤 많은 공간을 요구하기 때문에 디스크 여유 공간이 많이 있어야 합니다. 현재 4.15 버젼이 차지하는 디스크 공간은 __21.9GB__ 입니다. 앞으로 디스크 렌더 캐싱, 프로젝트 등 디스크 공간을 요구하는 일이 많아질 것입니다. 또한 빠른 설치를 위해 원활한 네트워크 환경에서 설치를 진행하시길 바랍니다.

이제 런처에서 엔진 바이너리를 설치합니다. 현재 최신 버젼인 4.15 버젼을 설치해줍니다.

엔진 설치가 끝나거나 환경이 원활하다면 [Visual Studio 2015 다운로드 페이지][vs2015-down]에서 다운로드 받아 설치합니다. IDE도 필요하지만 대부분 Windows 환경에서 실행하기 때문에 Windows SDK도 설치해주어야 합니다. 역시 많은 디스크 공간을 요구합니다. 또한 원활한 네트워크 환경에서 진행하길 바랍니다.

### 설치하면서 읽어볼 거리

 - [Scalability, 엔진 퀄리티와 개발자][ue4-scalability]

[myblog]: http://hrmrzizon.github.io
[ue4-offical]: https://www.unrealengine.com/ko
[ue4-doc]: https://docs.unrealengine.com/latest/KOR/index.html
[ue4-sample]: https://docs.unrealengine.com/latest/KOR/Resources/index.html
[cpuz-down]: http://www.cpuid.com/softwares/cpu-z.html
[vs2015-down]: https://www.visualstudio.com/ko/downloads/
[ue4-scalability]: https://docs.unrealengine.com/latest/KOR/Engine/Performance/Scalability/ScalabilityAndYou/index.html
