#include <simd/simd.h>
#include "boolean.h"

// Object information
struct Object {
    simd_float4 origin;
    simd_float4 bounds;
    simd_float4 objectData;
    simd_float4 tempData;
};

// Material
struct RayTracingMaterial {
    simd_float4 color;
};

// Scene info
struct RayTracedScene {
    struct Object objects[10];
    struct RayTracingMaterial materials[10];
    simd_float4 lengths;
};

// Screen size info
struct ScreenSize {
    float width;
    float height;
};

// Ray info
struct Ray {
    simd_float3 origin;
    simd_float3 direction;
};

// Hit info
struct HitInfo {
    boolean hit;
    float dist;
    
    simd_float3 hitPos;
    
    float materialIndex;
};

// Hit data
struct RayTracedHitInfo {
    float dist; // Distance the ray traveled

    boolean hit; // If the ray hit anything

    simd_float4 hitPos; // Hit position of the object
    simd_float4 normal; // Normal of the hit pos

    float materialIndex; // Material of the object the ray hit
};

// Point light
struct PointLight {
    simd_float4 origin;
    simd_float4 data;
};

// Uniforms
struct Uniforms {
    struct ScreenSize screenSize;
    float frameNum;
    float padding;
};
