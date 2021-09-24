---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - opengles
  - deferred_shading
---

 VR을 제외한 PC 및 콘솔 플랫폼에선 보통은 deferred shading 을 많이 사용한다. 거의 대부분은 MRT를 사용하여 각각의 프레임 버퍼로 픽셀 데이터를 저장하고, 마지막 패스에서 이를 다시 참조하여 계산한다. 이 방식은 필자가 아는 것 기준으로 10년이 넘어서도 주가되는 방식이다. 

 하지만 모바일 기기가 등장하고, 거의 대부분의 모바일 GPU 에서는 절대적으로 유닛 갯수가 부족하기 때문에 픽셀을 처리하는 ROP 유닛이 관여하는 부분을 타일로 나누어 _locality_ 를 이용하여 처리한다. (정점 처리는 그대로 간다. 그래서 절대적으로 정점의 한계는 명확하다.) 이 때문에 OpenGL ES 3.x 버젼이 현역인 때의 절대적인 문제점은 deferred shading 을 성능상의 문제로 사용할 수 없다는 점이였다. deferred shading 을 구현하는 방법은 무식하게 프레임버퍼를 크게 할당하여 하나하나 인코딩하는 방법이였는데, 픽셀을 타일 단위로 처리하는 방법을 가진 모바일 GPU 에서는 이전의 방법으로는 만족할만한 성능을 내기 어려웠다. 
 
 그래서 2014/2015 년에 MALI 제품군과 몇몇 PowerVR 제품군에서 사용 가능한 _pixel local storage_ 를 OGLES 에 _multi-vendor extension_ 분류로 등록되었다. 사용 방법은 GLES 쉐이더 소스를 수정하면 쉽게 변경 가능하다. _deferred shading_ 을 사용하기 위한 구체적인 예시를 아래에 가져와보았다. 역시 2 패스로 이루어진다.

<!-- more -->

 ```
     (1) Use the extension to write data.

    #version 300 es
    #extension GL_EXT_shader_pixel_local_storage : enable

    __pixel_localEXT FragDataLocal {
        layout(r11f_g11f_b10f) mediump vec3 normal;
        layout(rgb10_a2) highp vec4 color;
        layout(rgba8ui) mediump uvec4 flags;
    } gbuf;

    void main()
    {
        /* .... */
        gbuf.normal = v;
        gbuf.color = texture(sampler, coord);
        gbuf.flags = material_id;
    }
```

위 코드에서는 입력받은 기하를 PLS 에 저장하고, 아래 코드에서는 PLS 에서 참조하여 합치는 작업을 수행한다.

```
    (2) Use the extension to resolve the data.

    #version 300 es
    #extension GL_EXT_shader_pixel_local_storage : enable

    __pixel_localEXT FragDataLocal {
        layout(r11f_g11f_b10f) mediump vec3 normal;
        layout(rgb10_a2) highp vec4 color;
        layout(rgba8ui) mediump uvec4 flags;
    } gbuf;

 ```

 하지만 _pixel local storage_ 는 _ARB Extension_ 이 아니기 때문에 모든 벤더가 구현되었다고 볼 수 없고, 실제로 _adreno_ 제품군의 OpenGL 드라이버에는 구현되어 있지 않은 것으로 범용적으로는 쓰일 수 없는 것으로 보인다. OpenGL 드라이버를 사용하여 모바일 환경의 deffered 렌더링을 완벽하게 MRT 를 사용하여 최적화 할 수 없다.
 
 Vulkan 을 사용하여 deffered rendering 을 고안한 방법을 [khronos : Vulkan Subpasses](https://www.khronos.org/assets/uploads/developers/library/2016-vulkan-devday-uk/6-Vulkan-subpasses.pdf) 에서 볼 수 있다. 

## 참조

- [Pixel Local Storage on ARM Mali GPUs](https://community.arm.com/developer/tools-software/graphics/b/blog/posts/pixel-local-storage-on-arm-mali-gpus)
- [PowerVR Framework Tips and Tricks : Render pass/Pixel Local Storage (PLS) Strategies](https://docs.imgtec.com/Framework_DevGuide/topics/Tips_and_Tricks/Renderpass-PLS_Strategies/c_PVRFramework_subpasses_pls.html)
- [Apple Developer : About Imageblocks](https://developer.apple.com/documentation/metal/gpu_features/understanding_gpu_family_4/about_imageblocks)
- [khronos : EXT_shader_pixel_local_storage](https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_shader_pixel_local_storage.txt) 
- [khronos : EXT_shader_pixel_local_storage2](https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_shader_pixel_local_storage2.txt)
- [khronos : Vulkan Subpasses](https://www.khronos.org/assets/uploads/developers/library/2016-vulkan-devday-uk/6-Vulkan-subpasses.pdf)
