#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class SimpleShading {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            Light light = scene.light;
            float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w;
            
            float3 L = normalize(light.origin.xyz - hit.hitPos.xyz);
            
            return (light.albedo.xyz) * (float3(max(dot(normal, L), 0.0)) * material.albedo.xyz) + (ambient * light.albedo.xyz);
        }
};
