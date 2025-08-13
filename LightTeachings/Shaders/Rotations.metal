#include <metal_stdlib>

using namespace metal;

class Rotate {
public:
    // Rotation matrix around the X axis (Roll)
    float3x3 static rotateX(float angle) {
        
        angle *= -M_PI_F/180.0;
        
        float c = cos(angle);
        float s = sin(angle);
        return float3x3(
            float3(1.0, 0.0, 0.0),
            float3(0.0, c, -s),
            float3(0.0, s, c)
        );
    }
    
    // Rotation matrix around the Y axis (Yaw)
    float3x3 static rotateY(float angle) {
        
        angle *= M_PI_F/180.0;
        
        float c = cos(angle);
        float s = sin(angle);
        return float3x3(
            float3(c, 0.0, s),
            float3(0.0, 1.0, 0.0),
            float3(-s, 0.0, c)
        );
    }
    
    // Rotation matrix around the Z axis (Pitch, or sometimes Roll depending on convention)
    float3x3 static rotateZ(float angle) {
        
        angle *= M_PI_F/180.0;
        
        float c = cos(angle);
        float s = sin(angle);
        return float3x3(
            float3(c, -s, 0.0),
            float3(s, c, 0.0),
            float3(0.0, 0.0, 1.0)
        );
    }
    
    float3 static rotate(float3 vector, float3 angles) {
        return vector * (rotateZ(angles.x) * rotateX(angles.y) * rotateY(angles.z));
    }
};
