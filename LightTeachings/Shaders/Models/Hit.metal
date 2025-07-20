#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class Hit {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            return float3(hit.hit ? 1.0 : 0.0);
        }
};
