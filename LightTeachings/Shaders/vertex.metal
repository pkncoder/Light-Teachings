#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

constant float4 positions[] = {
    float4(-1.0, -1.0, 0.0, 1.0),
    float4( 1.0, -1.0, 0.0, 1.0),
    float4(-1.0, 1.0 , 0.0, 1.0),
    float4( 1.0, 1.0 , 0.0, 1.0)
};

VertexPayload vertex vertexMain(uint vertexID [[vertex_id]]) {
    VertexPayload payload;
    payload.position = positions[vertexID];
    return payload;
}

