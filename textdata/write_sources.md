# Practical Rendering

 - rendering pipeline 의 각각의 단계에 대해서 자세히 쓰기 - hull shader, domain shdaer 남음
 - visibility buffer
 - Terrain(GPU Pro 3,4,6)

 - Forward, Differed, Forward+, Differed+ 쓰기(inffered lighting, light pre-pass)

 - Scriptable Render Loop 분석하기
 - Tiled Lighting

 - Order Independant Transparency
 - Shadow mapping, Cascaded Shadow Mapping, Ray-Tracing Shadow, frustum-Tracing Shadow, Percentage-Closer Soft-Shadow

# Practical

- Simple Generational GC 쓰기
- Unity UGUI 해상도 관리하는 방법 쓰기
- Unity EventExecute Event 시스템

- merge conflict 에 대한 글 : merge, rebase, 3way merge, fast forward merge, conflict..
- git plumbling 명령어들 rev-parse, update-ref 등..

# Analysis

- 공개키, 개인키, 인증서, rsa, ssl, tcl, pgp
- megatexturing, splating textue

- dex, multidex, jackandjill

# rendering

<!-- Unity -->

 - SparseTexture
 - light prove, light volume
 - ambient occlusion : 미리 라이팅 계산해서 넣어놓기.. per-vertex ao 는 mesh 에 color 에 라이팅을 넣어줌.
 - global illumination : http://lifeisforu.tistory.com/52
 - texture bone animating

<!-- Unknowns -->

 - motion blur?
 - Hi-Z
 - CSM
 - fft convolution
 - mesh to mesh skinning or proxy skinnning
 - procedural animation
 - atmospheric scattering
 - alembic impoter
 - Unity : Granite, Scriptable rendering loop
 - Bipad : character animation
 - PBR : https://www.youtube.com/watch?v=0mxr6bFenfE
 - Unity : Per-Vertex Baked AO
