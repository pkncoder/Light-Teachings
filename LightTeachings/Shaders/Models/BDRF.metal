#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

class BDRF {
    private:
        float distributionGGX (float3 N, float3 H, float roughness){
            float a2    = roughness * roughness * roughness * roughness;
            float NdotH = max (dot (N, H), 0.0);
            float denom = (NdotH * NdotH * (a2 - 1.0) + 1.0);
            return a2 / (M_PI_F * denom * denom);
        }

        float geometrySchlickGGX (float NdotV, float roughness){
            float r = (roughness + 1.0);
            float k = (r * r) / 8.0;
            return NdotV / (NdotV * (1.0 - k) + k);
        }

        float geometrySmith (float3 N, float3 V, float3 L, float roughness){
            return geometrySchlickGGX (max (dot (N, L), 0.0), roughness) *
                   geometrySchlickGGX (max (dot (N, V), 0.0), roughness);
        }

        float3 fresnelSchlick (float cosTheta, float3 F0){
            return F0 + (1.0 - F0) * pow (1.0 - cosTheta, 5.0);
        }
    
public:
    float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
        
        float3 worldPos = hit.hitPos.xyz;
        float3 N = normal;
        float3 V = -ray.direction;
        float3 L = normalize(lightPos - worldPos);
        float3 H = normalize (V + L);

        ObjectMaterial material = scene.materials[hit.materialIndex - 1];
        Light light = scene.light;

        // Cook-Torrance BRDF
        float3  F0 = mix (float3 (0.04), pow(material.albedo.xyz, float3(2.2)), material.materialSettings[1]);
        float NDF = distributionGGX(N, H, material.materialSettings[0]);
        float G   = geometrySmith(N, V, L, material.materialSettings[0]);
        float3  F   = fresnelSchlick(max(dot(H, V), 0.0), F0);
        float3  kD  = float3(1.0) - F;
        kD *= 1.0 - material.materialSettings[1];

        float3  numerator   = NDF * G * F;
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0);
        float3  specular    = numerator / max(denominator, 0.001);

        float NdotL = max(dot(N, L), 0.0);

        float3 color = (light.albedo.xyz * light.albedo.w) * (kD * pow(material.albedo.xyz, float3(2.2)) / M_PI_F + specular) *
        (NdotL / dot(lightPos - worldPos, lightPos - worldPos)) + 0.05;
        
        return color;
        
    }
};
