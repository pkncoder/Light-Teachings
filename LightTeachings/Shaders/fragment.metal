#include <metal_stdlib>

#include "./RayMarcher.metal"

using namespace metal;

half4 fragment fragmentMain(VertexPayload frag [[stage_in]], constant RayTracedScene &scene [[buffer(1)]], constant Uniforms &uniforms [[buffer(2)]]) {

    ScreenSize screenSize = uniforms.screenSize;
    float _ = uniforms.frameNum;

    // Init important constant values
    float2 resolution = float2(screenSize.width, screenSize.height);
    float fieldOfView = 90;
    float aspectRatio = resolution.x / resolution.y; // Calculate the aspect ratio

    // Get the UV cordinates and map them to a -1 to 1 space
    float2 uv = ((frag.position.xy / resolution) * 2 - 1);
    uv.y *= -1; // Flip the y cordinate because of how (0, 0) is the top-left corner besides the bottom-left one

    // Get the camera distance from the FOV
    float cameraDistance = 1.0f / tan(fieldOfView * 0.5f * 3.14159 / 180.0f); // Get the camer distance from sphere (uses FOV)

    // Apply the aspect ratio to avoid screen stretching
    uv.y /= aspectRatio;

    // Create a ray using the uv and camera distance to get the ray directions
    Ray ray = {
        float3(0, 2, -6),
        normalize(float3(uv, cameraDistance))
    };
    
    // Create our modelinator (naming est difficile)
    Modelinator modelinator = Modelinator(BDRF_Model);
    
    switch((int)scene.renderingData.shadingInfo[0]) {
        case 1:
            modelinator = Modelinator(BDRF_Model);
            break;
        case 2:
            modelinator = Modelinator(SimpleShading_Model);
            break;
        case 3:
            modelinator = Modelinator(Hit_Model);
            break;
        case 4:
            modelinator = Modelinator(HitColor_Model);
            break;
        default:
            modelinator = Modelinator(BDRF_Model);
            break;
    }
    
    if (scene.renderingData.shadingInfo[1] > 0.0) {
        modelinator.setShadowOverride((bool) (scene.renderingData.shadingInfo[1] - 1.0));
    }

    // Create our ray marcher
    RayMarcher rayMarcher = RayMarcher(ray, scene);
    float3 color = rayMarcher.getColor(uv, scene.renderingData.arrayLengths.w, modelinator);


    // Output the final ray's color
    return half4(half3(color), 1.0);
}
