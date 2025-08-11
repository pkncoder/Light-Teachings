#include <metal_stdlib>

using namespace metal;

// Tone mapping
class ToneMapping {
public:
    // ACES Film Tone mapper
    //https://blog.demofox.org/2020/06/06/casual-shadertoy-path-tracing-2-image-improvement-and-glossy-reflections/
    static float3 ACESFilm(float3 x)
    {
        float a = 2.51f;
        float b = 0.03f;
        float c = 2.43f;
        float d = 0.59f;
        float e = 0.14f;
        return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
    }
};
