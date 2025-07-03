#include <simd/simd.h>
#include "boolean.h"

// Object information
struct Object {
    simd_float4 origin;
    simd_float4 bounds;
    simd_float4 objectData;
    simd_float4 tempData;
};

// Point light
struct PointLight {
    simd_float4 position;
    simd_float4 albedo;
};

// Material
struct ObjectMaterial {
    simd_float4 albedo;
    simd_float4 materialSettings;
};

// Bounding Box
struct BoundingBox {
    simd_float4 boxMin;
    simd_float4 boxMax;
};

// Scene info
struct RayTracedScene {
    struct Object objects[10];
    struct ObjectMaterial materials[10];
//    struct PointLight lights[10];
    struct BoundingBox topBoundingBox;
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
    
    int materialIndex;
};

// Uniforms
struct Uniforms {
    struct ScreenSize screenSize;
    float frameNum;
    float padding;
};
