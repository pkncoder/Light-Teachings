#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class HitColor {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            
            return (float3(hit.hit ? 1.0 : 0.0) * material.albedo.xyz);
        }
};
