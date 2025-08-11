#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

// Returns white if an object is hit, black if not
class Hit {
    public:
        // Coloring function
        float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            // Return the boolean as a float3
            return float3(hit.hit ? 1.0 : 0.0);
        }
};
