#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

class Random {

    uint rng_state;

    uint PCGHash()
    {
        rng_state = rng_state * 747796405u + 2891336453u;
        uint state = rng_state;
        uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
        return (word >> 22u) ^ word;
    }

public:
    // FragCoord and Time To Hash Uint
    // Seed must take a different value for each pixel every frame
    void  SetSeed( float2 fragCoord, int frame )
    {
        rng_state = uint(frame * 30.2345);
        rng_state = PCGHash();
        rng_state += uint(fragCoord.x);
        rng_state = PCGHash();
        rng_state += uint(fragCoord.y);
    }

    float rnd1(){
        return float(PCGHash()) / float(-1u);
    }

    float2 rnd2(){
        return float2(rnd1(),rnd1());
    }

    float3 rnd3() {
        return float3(rnd1(), rnd1(), rnd1());
    }
};
