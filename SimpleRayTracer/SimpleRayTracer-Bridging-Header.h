#include <simd/simd.h>
#include "boolean.h"

// Object information
struct Object {
    simd_float4 origin;
    simd_float4 bounds;
    simd_float4 data;
};

// Scene info
struct RayTracedScene {
    struct Object objects[10];
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
};
