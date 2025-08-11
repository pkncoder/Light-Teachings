#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

// Cook-Torrence BRDF
// Most of this is from https://learnopengl.com/PBR/Lighting where I learned this
//  Biggest Modification is I do HDR/Gamma Correction after (so the BRDF is not 100% physically accurate, however I'm not sure it was in the first place)
class BRDF {
    private:
    
        /* Distrobution function */
        float distributionGGX (float3 N, float3 H, float roughness){
            float a2 = roughness * roughness * roughness * roughness;
            float NdotH = max (dot (N, H), 0.0);
            float denom = (NdotH * NdotH * (a2 - 1.0) + 1.0);
            return a2 / (M_PI_F * denom * denom);
        }

        /* Geometry function */
        float geometrySchlickGGX (float NdotV, float roughness){
            float r = (roughness + 1.0);
            float k = (r * r) / 8.0;
            return NdotV / (NdotV * (1.0 - k) + k);
        }

        float geometrySmith (float3 N, float3 V, float3 L, float roughness){
            return geometrySchlickGGX (max (dot (N, L), 0.0), roughness) *
                   geometrySchlickGGX (max (dot (N, V), 0.0), roughness);
        }
        
        /* Frensel Factor */
        float3 fresnelSchlick (float cosTheta, float3 F0){
            return F0 + (1.0 - F0) * pow (1.0 - cosTheta, 5.0);
        }
    
public:
    // Coloring Function
    float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
        
        // Get the material, light, and ambient color (computed here)
        ObjectMaterial material = scene.materials[hit.materialIndex - 1];
        Light light = scene.light;
        float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * light.albedo.xyz * material.albedo.xyz;
        
        // Save important vectors
        float3 worldPos = hit.hitPos.xyz;
        float3 N = normal;
        float3 V = -ray.direction;
        float3 L = normalize(lightPos - worldPos);
        float3 H = normalize (V + L);

        // Cook-Torrance BRDF
        float3  F0 = mix (float3 (0.04), pow(material.albedo.xyz, float3(2.2)), material.materialSettings[1]);
        float NDF = distributionGGX(N, H, material.materialSettings[0]); // Normal Distrobution function
        float G = geometrySmith(N, V, L, material.materialSettings[0]); // Geometry function
        float3  F = fresnelSchlick(max(dot(H, V), 0.0), F0); // Frensel
        float3  kD = float3(1.0) - F; // Energy Conservation
        kD *= 1.0 - material.materialSettings[1]; // *If metalic then that's taken into account*

        // Numerator & Denominator of the Cook-Torrence BRDF (specular)
        float3  numerator = NDF * G * F;
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0);
        
        // Get the final specular amount (min value for the denominator slightly above zero to avoid deviding by 0)
        float3  specular = numerator / max(denominator, 0.001);

        // Shading factor
        float NdotL = max(dot(N, L), 0.0);

        // Get the final Color
        float3 color = ((light.albedo.xyz * light.albedo.w) * (kD * material.albedo.xyz / M_PI_F + specular)) *
        (NdotL / dot(lightPos - worldPos, lightPos - worldPos)) + ambient;
        
        // Return the final color
        return color;
        
    }
};
