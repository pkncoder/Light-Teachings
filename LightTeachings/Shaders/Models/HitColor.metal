#include "../../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

using namespace metal;

// Returns the color of whatever object it hit
class HitColor {
    public:
        // Coloring Function
        float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
            
            // Get the material
            ObjectMaterial material = scene.materials[hit.materialIndex - 1];
            
            // Return black if no object is hit, return the object's albedo if hit
            return (float3(hit.hit ? 1.0 : 0.0) * material.albedo.xyz);
        }
};
