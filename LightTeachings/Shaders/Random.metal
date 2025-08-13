#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

class Random {

    uint seed;

    uint PCGHash()
    {
        seed = seed * 747796405u + 2891336453u;
        uint state = seed;
        uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
        return (word >> 22u) ^ word;
    }

public:
    // FragCoord and Time To Hash Uint
    // Seed must take a different value for each pixel every frame
    void  setSeed( float2 fragCoord, int frame )
    {
        seed = uint(frame * 30.2345);
        seed = PCGHash();
        seed += uint(fragCoord.x);
        seed = PCGHash();
        seed += uint(fragCoord.y);
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
