---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - srp
---

# step by step : SRP

## 당위

srp 의 첫 등장은 unity 2018 이였고, 현재 글 작성 시점에선 시간이 꽤 많이 흘렀다. 처음에는 수많은 버그가 예측되어 잘 사용하지 않지만, 지금은 시간이 꽤나 흘러 프로덕션에의 도입도 고려해볼 법 하다. 수많은 [버그 픽스]({{ site.baseurl }}{% post_url 2022-04-11-unity-core-rp-changelog-unique %})를 통해 어느 정도 안정되었을 것 같다? 라고 생각한다. 아직은 어떤 프로덕트에서 쓰였다는 소식은 듣지 못했지만, 추후 사용을 위해 간단하게 접근해본다.

이 글에서는 간단하게 물체를 렌더링 하는 것까지만 한다.

- _Unity 2021.3.0f1_, _com.unity.render-pipelines.core@14.0_ 기준으로 작성됨

<!-- more -->

## 시작

### 프로젝트 세팅

Unity 의 pre-buitld srp 는 사용하지 않으므로, 이를 제외한 아무 프로젝트나 만든다.

![create project](/images/step-0-create-project.PNG)

_Core RP_ 라이브러리를 설치해준다. _Windwos -> Package Manager_ 에서, _Unity Registry_ 를 선택하면 리스트에 `core rp` 가 나온다. 우측 하단에 install 을 누른다.

![install core rp](/images/step-0-install-core-rp.PNG)

_ProjectSettings -> Graphics_ 에 들어가면 나오느 비어있는 _render pipeline assets_ 에다가 `ScriptableObject` 기반인 `RenderPipelineAssets` 를 만들어 넣어주면 된다. 빌트인으로 만들어서 아무것도 없다.

![graphics settings empty](/images/step-0-graphics-settings-empty.PNG)

우선 에셋 스크립트를 작성한다. 간단히 아무것도 하지 않는 것부터 만든다.

``` csharp
[CreateAssetMenu]
public sealed class S0RenderPipelineAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline()
    {
        return null;
    }
}
```

이 후 에셋을 만들고 _ProjectSettings -> Graphics_ 로 가서, 만든 _rp asset_ 을 넣어본다. 그러면 아무것도 안나온다. 정상 화면을 보고 싶으면 rp 에셋을 빼면 된다.

![create rp assets](/images/step-0-create-rp-assets.PNG)
![empty scene](/images/step-0-empty-scene.PNG)

### Render Pipeline

이제 본격적으로 `Render Pipline` 코딩을 해보자. `UnityEngine.Rendering.RenderPipeline` 을 상속받아 `Render` 메소드를 구현하자. 시작은 간단하게 스카이박스만 뿌린다.

``` csharp
[CreateAssetMenu]
public sealed class S0RenderPipelineAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline()
    {
        return new S0RenderPipeline();
    }
}
```

``` csharp
public class S0RenderPipeline : RenderPipeline
{
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        for (var i = 0; i < cameras.Length; i++)
        {
            var camera = cameras[i];

            context.SetupCameraProperties(camera);
            context.DrawSkybox(camera);
        }

        context.Submit();
    }
}
```

`RenderPipeline.Render` 는 넘겨준 context 와 전체 활성화된 카메라를 준다. 이를 활용해 렌더링을 하면되고, skybox 만 그려주었다. `SetupCameraProperties` 에선 카메라의 회전을 포함한 인자를 세팅하고, `DrawSkybox` 에선 스카이박스 렌더링 세팅을 한다. 그리고 마지막에 세팅된 모든 것들을 `Submit` 한다. 아마 실질적인 렌더링은 여기서 이루어지는 것 같다. 이러한 구조는 DX12 나 Vulkan 에서 아이디어를 얻은 것으로 보인다. 이전부터 지원하던 `CommandBuffer` 의 확장판 같다.

이제 오브젝트를 그려보자. `Scene` 에 기본으로 생성 가능한 오브젝트를 만들고, 코드를 아래처럼 고친다.

``` csharp
protected override void Render(ScriptableRenderContext context, Camera[] cameras)
{
    for (var i = 0; i < cameras.Length; i++)
    {
        var camera = cameras[i];

        context.SetupCameraProperties(camera);

        // 추가 코드
        if (!camera.TryGetCullingParameters(false, out var properties))
            continue;
        
        var cullingResults = context.Cull(ref properties);
        var sortSettings = new SortingSettings(camera);
        var drawSettings = new DrawingSettings(new ShaderTagId("FORWARDBASE"), sortSettings);
        var filterSettings = new FilteringSettings(RenderQueueRange.all);
        
        context.DrawRenderers(cullingResults, ref drawSettings, ref filterSettings);
        // 추가 코드

        context.DrawSkybox(camera);
    }

    context.Submit();
}
```

추가된 코드의 절차는 다음과 같다.

1. 컬링하기
2. 카메라 기준으로 소팅하기
3. 어떤 태그의 메터리얼을 그릴지, 소팅은 어떻게 할지 결정하기
4. 어떤 RenderQueue 를 그릴지 필터링 하기
5. 위 정보를 기반으로 MeshRenderer/SkinnedMeshRenderer 그리기

그러면 아래와 같이 cube 들이 나온다. `FORWARDBASE` 는 Standard 쉐이더의 일부다.

![render standard cube](/images/step-0-render-standard-cube.PNG)

[저장소](https://github.com/suhyeokkim/CustomSRPPractice/tree/step-0)에서 연관 소스를 받을 수 있다. 블로그의 글과는 구조가 약간 다르다. 컨텍스트/렌더러 를 아예 나누고, 연관 CommandBuffer 를 미리 할당해두었다.

## 참조 문서

- [CHANGELOG : com.unity.render-pipelines.core@14.0](https://docs.unity3d.com/Packages/com.unity.render-pipelines.core@14.0/changelog/CHANGELOG.html)
- [catlikecoding : Custom Pipeline](https://catlikecoding.com/unity/tutorials/scriptable-render-pipeline/custom-pipeline/)