#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class SimpleShading {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            
            float3 L = normalize(lightPos - hit.hitPos.xyz);
            
            return (float3(max(dot(normal, L), 0.0)) * material.albedo.xyz);
        }
};
