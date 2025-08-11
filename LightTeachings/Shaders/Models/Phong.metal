#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class Phong {
    public:
        float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            // Get the material, light, and ambient (computed here)
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            Light light = scene.light;
            float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * light.albedo.xyz * material.albedo.xyz;
            
            // Light vector
            float3 lightDir = normalize(light.origin.xyz - hit.hitPos.xyz);
            
            // Diffuse component
            float3 diffuse = max(dot(normal, lightDir), 0.0) * light.albedo.xyz * material.albedo.xyz;
            
            // Reflected light
            float3 reflectDir = reflect(-lightDir, normal);
            
            // Specular component
            float spec = pow(max(dot(normalize(ray.origin - hit.hitPos), reflectDir), 0.0), 32);
            float3 specular = abs(material.materialSettings[0] - 1.0) * spec * light.albedo.xyz;
            
            // Combined color
            return (specular + diffuse + ambient);
        }
};
