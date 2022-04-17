---
layout: post
author: "Su-Hyeok Kim"
comments: true
categories:
  - unity
  - srp
---

2019 부터 srp 가 정식 릴리즈 되었다. 현 회사 프로젝트는 pre-built srp 를 쓰기엔 이것저것 붙여놓은 상태라 애매해서 core rp 라이브러리 부터 확인할 필요가 있다. 어떤 차이가 있는지 확인하기 위해 관련 정보를 번역하고 저장한다. 2019 -> 2020 -> 2021 의 차이를 기록하고, 중복되는 내용이 있다면 제거한다. (예: 2019 릴리즈 <-> 2020 초기) 변경 사항은 버젼 오름차순으로 정리한다.

- [마지막 참조 : com.unity.render-pipelines.core@14.0](https://docs.unity3d.com/Packages/com.unity.render-pipelines.core@14.0/changelog/CHANGELOG.html)

<!-- more -->

# 2020

## [10.1.0] - 2020-10-12

### Added

Added context options "Move to Top", "Move to Bottom", "Expand All" and "Collapse All" for volume components.
Added the support of input system V2

### Fixed

Fixed the scene view to scale correctly when hardware dynamic resolution is enabled (case 1158661)
Fixed game view artifacts on resizing when hardware dynamic resolution was enabled

### Changed

LookDev menu item entry is now disabled if the current pipeline does not support it.

## [10.0.0] - 2019-06-10

### Added

Add XRGraphicsAutomatedTests helper class.

### Fixed

Fixed division by zero in V_SmithJointGGX function.
Fix a compil error on OpenGL ES2 in directional lightmap sampling shader code
Fix artifacts on Adreno 630 GPUs when using ACES Tonemapping
Fixed a null ref in the volume component list when there is no volume components in the project.
Fixed issue with volume manager trying to access a null volume.

### Changed

Updated shaders to be compatible with Microsoft's DXC.
Changed CommandBufferPool.Get() to create an unnamed CommandBuffer. (No profiling markers)

## [10.3.0] - 2020-11-16

### Added

New function in GeometryTools.hlsl to calculate triangle edge and full triangle culling.

### Fixed

Fixed a bug in FreeCamera which would only provide a speed boost for the first frame when pressing the Shfit key.
Fixed missing warning UI about Projector component being unsupported (case 1300327).

## [10.4.0] - 2021-03-11

### Added

New API in DynamicResolutionHandler to handle multicamera rendering for hardware mode. Changing cameras and resetting scaling per camera should be safe.
New API functions with no side effects in DynamicResolutionHandler, to retrieve resolved drs scale and to apply DRS on a size.

### Fixed

Fixed parameters order on inspectors for Volume Components without custom editor
Fixed the display name of a Volume Parameter when is defined the attribute InspectorName
Calculating correct rtHandleScale by considering the possible pixel rounding when DRS is on

# 2021

## [11.0.0] - 2020-10-21

### Fixed

Fixed the default background color for previews to use the original color.
Fixed spacing between property fields on the Volume Component Editors.
Fixed ALL/NONE to maintain the state on the Volume Component Editors.
Fixed the selection of the Additional properties from ALL/NONE when the option "Show additional properties" is disabled
Fixed ACES tonemaping for Nintendo Switch by forcing some shader color conversion functions to full float precision.

### Added

New View Lighting Tool, a component which allow to setup light in the camera space
Several utils functions to access SphericalHarmonicsL2 in a more verbose and intuitive fashion.

## [12.0.0] - 2021-01-11

### Added

Support for additional properties for Volume Components without custom editor
Added VolumeComponentMenuForRenderPipelineAttribute to specify a volume component only for certain RenderPipelines.
Added Editor window that allow showing an icon to browse the documentation
New method DrawHeaders for VolumeComponentsEditors
Unification of Material Editor Headers Scopes
Added helper for Volumes (Enable All Overrides, Disable All Overrides, Remove All Overrides).
Added a blitter utility class. Moved from HDRP to RP core.
Added a realtime 2D texture atlas utility classes. Moved from HDRP to RP core.
New methods on CoreEditorDrawers, to allow adding a label on a group before rendering the internal drawers
Method to generate a Texture2D of 1x1 with a plain color
Red, Green, Blue Texture2D on CoreEditorStyles
Added SpeedTree8MaterialUpgrader, which provides utilities for upgrading and importing SpeedTree 8 assets to scriptable render pipelines.
Adding documentation links to Light Sections
Support for Lens Flare Data Driven (from images and Procedural shapes), on HDRP
New SRPLensFlareData Asset
Adding documentation links to Light Sections.
Added sampling noise to probe volume sampling position to hide seams between subdivision levels.
Added DebugUI.Foldout.isHeader property to allow creating full-width header foldouts in Rendering Debugger.
Added DebugUI.Flags.IsHidden to allow conditional display of widgets in Rendering Debugger.
Added "Expand/Collapse All" buttons to Rendering Debugger window menu.
Added mouse & touch input support for Rendering Debugger runtime UI, and fix problems when InputSystem package is used.
Add automatic spaces to enum display names used in Rendering Debugger and add support for InspectorNameAttribute.
Adding new API functions inside DynamicResolutionHandler to get mip bias. This allows dynamic resolution scaling applying a bias on the frame to improve on texture sampling detail.
Added a reminder if the data of probe volume might be obsolete.
Added new API function inside DynamicResolutionHandler and new settings in GlobalDynamicResolutionSettings to control low res transparency thresholds. This should help visuals when the screen percentage is too low.
Added common include file for meta pass functionality (case 1211436)
Added OverridablePropertyScope (for VolumeComponentEditor child class only) to handle the Additional Property, the override checkbox and disable display and decorator attributes in one scope.
Added IndentLevelScope (for VolumeComponentEditor child class only) to handle indentation of the field and the checkbox.
Added an option to change the visibilty of the Volumes Gizmos (Solid, Wireframe, Everything), available at Preferences > Core Render Pipeline
Added class for drawing shadow cascades UnityEditor.Rendering.ShadowCascadeGUI.DrawShadowCascades.
Added UNITY_PREV_MATRIX_M and UNITY_PREV_MATRIX_I_M shader macros to support instanced motion vector rendering
Added new API to customize the rtHandleProperties of a particular RTHandle. This is a temporary work around to assist with viewport setup of Custom post process when dealing with DLSS or TAAU
Added IAdditionalData interface to identify the additional datas on the core package.
Added new API to draw color temperature for Lights.

### Fixed

Help boxes with fix buttons do not crop the label.
Problem on domain reload of Volume Parameter Ranges and UI values
Fixed Right Align of additional properties on Volume Components Editors
Fixed normal bias field of reference volume being wrong until the profile UI was displayed.
Fixed L2 for Probe Volumes.
When adding Overrides to the Volume Profile, only show Volume Components from the current Pipeline.
Fixed assertion on compression of L1 coefficients for Probe Volume.
Explicit half precision not working even when Unified Shader Precision Model is enabled.
Fixed ACES filter artefact due to half float error on some mobile platforms.
Fixed issue displaying a warning of different probe reference volume profiles even when they are equivalent.
Fixed missing increment/decrement controls from DebugUIIntField & DebugUIUIntField widget prefabs.
Fixed IES Importer related to new API on core.
Fixed a large, visible stretch ratio in a LensFlare Image thumbnail.
Fixed Undo from script refreshing thumbnail.
Fixed cropped thumbnail for Image with non-uniform scale and rotation
Skip wind calculations for Speed Tree 8 when wind vector is zero (case 1343002)
Fixed memory leak when changing SRP pipeline settings, and having the player in pause mode.
Fixed alignment in Volume Components
Virtual Texturing fallback texture sampling code correctly honors the enableGlobalMipBias when virtual texturing is disabled.
Fixed LightAnchor too much error message, became a HelpBox on the Inspector.
Fixed library function SurfaceGradientFromTriplanarProjection to match the mapping convention used in SampleUVMappingNormalInternal.hlsl and fix its description.
Fixed Volume Gizmo size when rescaling parent GameObject
Fixed rotation issue now all flare rotate on positive direction (1348570)
Fixed error when change Lens Flare Element Count followed by undo (1346894)
Fixed Lens Flare Thumbnails
Fixed Lens Flare 'radialScreenAttenuationCurve invisible'
Fixed Lens Flare rotation for Curve Distribution
Fixed potentially conflicting runtime Rendering Debugger UI command by adding an option to disable runtime UI altogether (1345783).
Fixed Lens Flare position for celestial at very far camera distances. It now locks correctly into the celestial position regardless of camera distance (1363291)
Fixed issues caused by automatically added EventSystem component, required to support Rendering Debugger Runtime UI input. (1361901)

### Changed

Improved the warning messages for Volumes and their Colliders.
Changed Window/Render Pipeline/Render Pipeline Debug to Window/Analysis/Rendering Debugger
Changed Window/Render Pipeline/Look Dev to Window/Analysis/Look Dev
Changed Window/Render Pipeline/Render Graph Viewer to Window/Analysis/Render Graph Viewer
Changed Window/Render Pipeline/Graphics Compositor to Window/Rendering/Graphics Compositor
Volume Gizmo Color setting is now under Colors->Scene->Volume Gizmo
Volume Gizmo alpha changed from 0.5 to 0.125
Moved Edit/Render Pipeline/Generate Shader Includes to Edit/Rendering/Generate Shader Includes
Moved Assets/Create/LookDev/Environment Library to Assets/Create/Rendering/Environment Library (Look Dev)
Changed Nintendo Switch specific half float fixes in color conversion routines to all platforms.
Improved load asset time for probe volumes.
ClearFlag.Depth does not implicitely clear stencil anymore. ClearFlag.Stencil added.
The RTHandleSystem no longer requires a specific number of sample for MSAA textures. Number of samples can be chosen independently for all textures.
Platform ShaderLibrary API headers now have a new macro layer for 2d texture sampling macros. This layer starts with PLATFORM_SAMPLE2D definition, and it gives the possibility of injecting sampling behavior on a render pipeline level. For example: being able to a global mip bias for temporal upscalers.
Update icon for IES, LightAnchor and LensFlare
LensFlare (SRP) can be now disabled per element
LensFlare (SRP) tooltips now refer to meters.
Serialize the Probe Volume asset as binary to improve footprint on disk and loading speed.
LensFlare Element editor now have Thumbnail preview
Improved IntegrateLDCharlie() to use uniform stratified sampling for faster convergence towards the ground truth
DynamicResolutionHandler.GetScaledSize function now clamps, and never allows to return a size greater than its input.
Removed DYNAMIC_RESOLUTION snippet on lens flare common shader. Its not necessary any more on HDRP, which simplifies the shader.
Made occlusion Radius for lens flares in directional lights, be independant of the camera's far plane.

## [13.0.0] - 2021-09-01

Version Updated The version number for this package has increased due to a version update of a related graphics package.

### Added
New IVolumeDebugSettings interface and VolumeDebugSettings<T> class that stores the information for the Volumes Debug Panel.
Added AMD FidelityFX shaders which were originally in HDRP
Added support for high performant unsafe (uint only) Radix, Merge and Insertion sort algorithms on CoreUnsafeUtils.
### Fixed
Fixed black pixel issue in AMD FidelityFX RCAS implementation
Fixed a critical issue on android devices & lens flares. Accidentally creating a 16 bit texture was causing gpus not supporting them to fail.
Fixed serialization of DebugStateFlags, the internal Enum was not being serialized.

## [13.1.0] - 2021-09-24

### Added

Debug Panels Framework See IDebugDisplaySettingsQuery.

### Fixed

Fixed keyword and float property upgrading in SpeedTree8MaterialUpgrader

## [13.1.1] - 2021-10-04

### Added

Added support for high performant unsafe (uint only) Radix, Merge and Insertion sort algorithms on CoreUnsafeUtils.
Added DebugFrameTiming class that can be used by render pipelines to display CPU/GPU frame timings and bottlenecks in Rendering Debugger.
Added new DebugUI widget types: ProgressBarValue and ValueTuple
Added common support code for FSR.
Added new RenderPipelineGlobalSettingsProvider to help adding a settings panel for editing global settings.
Added blending for curves in post processing volumes.

## [13.1.2] - 2021-11-05

### Added

Added function to allocate RTHandles using RenderTextureDescriptor.
Added vrUsage support for RTHandles allocation.

### Fixed

Fixed issue when changing volume profiles at runtime with a script (case 1364256).
Fixed XR support in CoreUtils.DrawFullscreen function.
Fixed an issue causing Render Graph execution errors after a random amount of time.

## [14.0.0] - 2021-11-17

### Added

Context menu on Volume Parameters to restore them to their default values.

### Fixed

Fixed XR support in CoreUtils.DrawFullscreen function.
