#pragma once

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
struct ObjectMaterial {
    simd_float4 albedo;
    simd_float4 materialSettings;
    simd_float4 temp1;
    simd_float4 temp2;
};

// Point light
struct PointLight {
    simd_float4 position;
    simd_float4 albedo;
};

// Bounding Box
struct BoundingBox {
    simd_float4 boxMin;
    simd_float4 boxMax;
    simd_float4 temp1;
    simd_float4 temp2;
};

// Renderer data
struct RendererData {
    simd_float4 arrayLengths;
    simd_float4 shadingInfo;
    simd_float4 temp2;
    simd_float4 temp3;
};

// Scene info
struct RayTracedScene {
    struct Object objects[10];
    struct ObjectMaterial materials[10];
//    struct PointLight lights[10];
    struct BoundingBox topBoundingBox;
    struct RendererData renderingData;
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
    simd_float4 temp1;
    simd_float4 temp2;
    simd_float4 temp3;
};

// Vertex function payload
struct VertexPayload {
    simd_float4 position [[position]];
    simd_half3 color;

};
