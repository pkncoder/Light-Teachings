#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class Phong {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            
            float3 lightDir = normalize(lightPos - hit.hitPos.xyz);
            
            float3 diffuse = max(dot(normal, lightDir), 0.0);
            
            
//            vec3 viewDir = normalize(viewPos - FragPos);
            float3 reflectDir = reflect(-lightDir, normal);
            
            float spec = pow(max(dot(normalize(ray.origin - hit.hitPos), reflectDir), 0.0), 32);
            float3 specular = 1.0 * spec;
            
            float4 ambient = scene.renderingData.ambient;
            
            return (specular + diffuse + ambient.xyz * ambient.w) * material.albedo.xyz;
        }
};
