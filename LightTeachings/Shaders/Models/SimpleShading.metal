#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

// Basic diffuse shading
class SimpleShading {
    public:
        // Coloring function
        float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            // Save the material data, light info, and ambient color (computed here into float3)
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            Light light = scene.light;
            float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * light.albedo.xyz * material.albedo.xyz;
            
            // Get the light vector
            float3 L = normalize(light.origin.xyz - hit.hitPos.xyz);
            
            // Compute the diffuse color with NdotL shading
            float3 diffuse = float3(max(dot(normal, L), 0.0)) * light.albedo.xyz * material.albedo.xyz;
            
            // Return the diffuse and ambient color
            return diffuse + ambient;
        }
};
