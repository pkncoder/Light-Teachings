#include <metal_stdlib>

//#include "./RayMarcher.metal"
#include "./RayTracer.metal"

using namespace metal; // I'm sorry stack overflow but I'm going to use a namespace

// Start fragment function from the renderer
half4 fragment fragmentMain(VertexPayload frag [[stage_in]], constant RayTracedScene &scene [[buffer(1)]], constant Uniforms &uniforms [[buffer(2)]]) {

    // Screen size / resolution
    ScreenSize screenSize = uniforms.screenSize;

    // Get the resolution, FOV, and aspect ratio
    float2 resolution = float2(screenSize.width, screenSize.height);
    float fieldOfView = 90;
    float aspectRatio = resolution.x / resolution.y;

    // Get the uv corrdinates
    float2 uv = ((frag.position.xy / resolution) * 2 - 1) * float2(aspectRatio, -1.0);

    // Get the camera distance for FOV
    float cameraDistance = 1.0f / tan(fieldOfView * 0.5f * 3.14159 / 180.0f); // Get the camer distance from sphere (uses FOV)

    // Get the current ray
    Ray ray = {
        float3(0, 2, -6),
        normalize(float3(uv, cameraDistance))
    };
    
    // Init a modelinator (with a BRDF_Model as placeholder)
    Modelinator modelinator = Modelinator(BRDF_Model);
    
    // Switch the render data's shading model to get the right one and save it to our modelinator
    switch((int)scene.renderingData.shadingInfo[0]) {
        case 1:
            modelinator = Modelinator(BRDF_Model);
            break;
        case 2:
            modelinator = Modelinator(Phong_Model);
            break;
        case 3:
            modelinator = Modelinator(SimpleShading_Model);
            break;
        case 4:
            modelinator = Modelinator(Hit_Model);
            break;
        case 5:
            modelinator = Modelinator(HitColor_Model);
            break;
        default:
            modelinator = Modelinator(BRDF_Model);
            break;
    }
    
    // Get the shadowing override
    float shadowingOverride = scene.renderingData.shadingInfo[1];
    
    // If we need to override anything
    if (shadowingOverride > 0.0) {
        modelinator.setShadowOverride((bool) (shadowingOverride - 1.0)); // Set the modelinator shadowing override
    }

    // Init our ray tracer and get the color from the coloring function
    RayTracer rayTracer = RayTracer(ray, scene);
    float3 color = rayTracer.getColor(uv, modelinator);

    // Return the final coloring function (and convert from float3 to half4)
    return half4(half3(color), 1.0);
}
