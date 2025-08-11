#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

// Triangle strip positions
constant float4 positions[] = {
    float4(-1.0, -1.0, 0.0, 1.0),
    float4( 1.0, -1.0, 0.0, 1.0),
    float4(-1.0, 1.0 , 0.0, 1.0),
    float4( 1.0, 1.0 , 0.0, 1.0)
};

// Start vertex function from the renderer
VertexPayload vertex vertexMain(uint vertexID [[vertex_id]]) {
    
    // Set where the vertex is at the current pos
    VertexPayload payload;
    payload.position = positions[vertexID];
    
    // Send the payload to the fragment shader
    return payload;
}

