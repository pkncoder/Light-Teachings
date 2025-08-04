#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

class Phong {
    public:
        float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            Light light = scene.light;
            float3 lightColor = light.albedo.xyz;
            
            float3 lightDir = normalize(light.origin.xyz - hit.hitPos.xyz);
            
            float3 diffuse = max(dot(normal, lightDir), 0.0) * lightColor * material.albedo.xyz;
            
            
//            vec3 viewDir = normalize(viewPos - FragPos);
            float3 reflectDir = reflect(-lightDir, normal);
            
            float spec = pow(max(dot(normalize(ray.origin - hit.hitPos), reflectDir), 0.0), 32);
            float3 specular = 1.0 * spec * lightColor;
            
            float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * lightColor;
            
            return (specular + diffuse + ambient);
        }
};
