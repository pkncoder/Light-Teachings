#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

class BDRF {
    public:
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
};
