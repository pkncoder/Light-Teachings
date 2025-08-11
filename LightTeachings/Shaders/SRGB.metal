#include <metal_stdlib>

using namespace metal;

// SRGB functions
//https://blog.demofox.org/2020/06/06/casual-shadertoy-path-tracing-2-image-improvement-and-glossy-reflections/
class SRGB {
private:
    static float3 LessThan(float3 f, float value)
    {
        return float3(
                      (f.x < value) ? 1.0f : 0.0f,
                      (f.y < value) ? 1.0f : 0.0f,
                      (f.z < value) ? 1.0f : 0.0f);
    }
    
public:
    // To SRGB
    static float3 LinearToSRGB(float3 rgb)
    {
        rgb = clamp(rgb, 0.0f, 1.0f);
        
        return mix(
                   pow(rgb, float3(1.0f / 2.4f)) * 1.055f - 0.055f,
                   rgb * 12.92f,
                   LessThan(rgb, 0.0031308f)
                   );
    }
    
    // From SRGB
    static float3 SRGBToLinear(float3 rgb)
    {
        rgb = clamp(rgb, 0.0f, 1.0f);
        
        return mix(
                   pow(((rgb + 0.055f) / 1.055f), float3(2.4f)),
                   rgb / 12.92f,
                   LessThan(rgb, 0.04045f)
                   );
    }
};
