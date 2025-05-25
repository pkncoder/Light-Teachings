#include "LightTeachings-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

struct VertexPayload {
    float4 position [[position]];
    half3 color;

};

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




float3 SphereicalCapVNDFSampling(float2 u, float3 wi, float alpha_x, float alpha_y)
{
    wi = wi.xzy;
    wi = normalize(float3(alpha_x * wi.x, alpha_y * wi.y, wi.z));

    float phi = 2.0f * M_PI_F * u.x;
    float z = fma((1.0f - u.y), (1.0f + wi.z), -wi.z);
    float sinTheta = sqrt(clamp(1.0f - z * z, 0.0f, 1.0f));
    float x = sinTheta * cos(phi);
    float y = sinTheta * sin(phi);
    float3 c = float3(x, y, z);

    float3 h = c + wi;
    
    float3 wo = normalize(float3(alpha_x * h.x, alpha_y * h.y, h.z));
    wo = wo.xzy;
    
    return wo;
}




class BDRF {
    public:
        float distributionGGX (float3 N, float3 H, float roughness){
            float a2    = roughness * roughness * roughness * roughness;
            float NdotH = max (dot (N, H), 0.0);
            float denom = (NdotH * NdotH * (a2 - 1.0) + 1.0);
            return a2 / (M_PI_F * denom * denom);
        }

        float geometrySchlickGGX (float NdotV, float roughness){
            float r = (roughness + 1.0);
            float k = (r * r) / 8.0;
            return NdotV / (NdotV * (1.0 - k) + k);
        }

        float geometrySmith (float3 N, float3 V, float3 L, float roughness){
            return geometrySchlickGGX (max (dot (N, L), 0.0), roughness) *
                   geometrySchlickGGX (max (dot (N, V), 0.0), roughness);
        }

        float3 fresnelSchlick (float cosTheta, float3 F0){
            return F0 + (1.0 - F0) * pow (1.0 - cosTheta, 5.0);
        }
};

class RayMarcher {
// MARK: -Private-
private:
    Ray ray;
    RayTracedScene scene;
    
    float epsilon;
    float maxSteps;
    float maxDist;
    
    // MARK: -Object SDFs-
    
    // Thanks iq: https://iquilezles.org/articles/distfunctions/
    
    // Sphere
    float sphereSDF( Ray ray, Object sphere ) {
        return length(sphere.origin.xyz - ray.origin) - sphere.bounds.w;
    }
    
    // Box
    float boxSDF( Ray ray, Object box )
    {
        float3 d = abs(box.origin.xyz - ray.origin) - box.bounds.xyz;
        return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
    }

    // Rounded Box
    float roundedBoxSDF( Ray ray, Object box)
    {
        float3 q = abs(box.origin.xyz - ray.origin) - box.bounds.xyz + box.bounds.w;
        return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.bounds.w;
    }
    
    // Outlined Box
    float outlinedBoxSDF( Ray ray, Object box)
    {
        float3 p = abs(box.origin.xyz - ray.origin)-box.bounds.xyz;
        float3 q = abs(p+box.bounds.w)-box.bounds.w;
        return min(min(
          length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
          length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
          length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
    }
    
    // Plane
    float planeSDF( Ray ray, Object plane )
    {
        return dot(ray.origin.xyz - plane.origin.xyz, normalize(plane.bounds.xyz)) - plane.origin.w;
    }
    
    // Cylinder
    float cylinderSDF( Ray ray, Object cylinder )
    {
      ray.origin = cylinder.origin.xyz - ray.origin;
      float2 d = abs(float2(length(ray.origin.xz),ray.origin.y)) - float2(cylinder.bounds.w,cylinder.bounds.y);
      return min(max(d.x,d.y),0.0) + length(max(d,0.0));
    }
    
    
    // MARK: -Object Functions-
    
    // Lightings
    float3 estimateNormal(Ray ray) {
        
        // Get the normal ray hit
        HitInfo rayHit = sceneSDF(ray);
        
        // Get the new rays with epsilon modifications
        Ray rayPOne = {ray.origin + float3(epsilon, 0, 0), ray.direction};
        Ray rayPTwo = {ray.origin + float3(0, epsilon, 0), ray.direction};
        Ray rayPThree = {ray.origin + float3(0, 0, epsilon), ray.direction};
        
        // Estimate the final normal
        return normalize(float3(
            sceneSDF(rayPOne).dist - rayHit.dist,
            sceneSDF(rayPTwo).dist - rayHit.dist,
            sceneSDF(rayPThree).dist - rayHit.dist
        ));
    }
    
    // MARK: -SDF Opperations-
    
    // SDF things
    float intersectSDFs(float distA, float distB) {
        return max(distA, distB);
    }

    float unionSDFs(float distA, float distB) {
        return min(distA, distB);
    }

    float differenceSDFs(float distA, float distB) {
        return max(distA, -distB);
    }
    
    // MARK: -Scene mapping-
    
    HitInfo getObjectHit(Ray ray) {
        
        // differenceSDFs(boxSDF(ray, scene.objects[0]), roundedBoxSDF(ray, scene.objects[1]));
        
        // Declare variables
        float finalDistance = -1.0; // Initialized to -1.0 for the start
        float objectDistance;
        float operationNumber;
        Object finalObject = scene.objects[0];
        
        // Loop every object
        for (int objectNum = 0; objectNum < scene.lengths[0]; objectNum++) {
            
            // Get said object
            Object currentObject = scene.objects[objectNum];
            
            
            // Get this object distance
            if (currentObject.objectData[0] == 1) {          // Sphere
                objectDistance = sphereSDF(ray, currentObject);
            } else if (currentObject.objectData[0] == 2) {   // Box
                objectDistance = boxSDF(ray, currentObject);
            } else if (currentObject.objectData[0] == 3) {   // Rounded Box
                objectDistance = roundedBoxSDF(ray, currentObject);
            } else if (currentObject.objectData[0] == 4) {   // Outlined Box
                objectDistance = outlinedBoxSDF(ray, currentObject);
            } else if (currentObject.objectData[0] == 5) {   // Plane
                objectDistance = planeSDF(ray, currentObject);
            } else if (currentObject.objectData[0] == 6) {   // Cylinder
                objectDistance = cylinderSDF(ray, currentObject);
            } else {                            // Default
                objectDistance = sphereSDF(ray, currentObject);
            }
            
            
            // Perform any opperations
            
//             If there is no previous distance held
            if (finalDistance == -1.0) {
                
                // Set the object distance to the final one
                finalDistance = objectDistance;
                finalObject = currentObject;
                
                // Set the operation number
                operationNumber = currentObject.objectData[1];
                
                // Skip to the next spot
                continue;
            }
            
            // If the opperation number is set
            if (operationNumber == 0) {          // Union
                finalDistance = unionSDFs(finalDistance, objectDistance);
            } else if (operationNumber == 1) {   // Difference
                finalDistance = differenceSDFs(finalDistance, objectDistance);
            } else if (operationNumber == 2) {   // Intersect
                finalDistance = intersectSDFs(finalDistance, objectDistance);
            } else {                             // Default - Union
                finalDistance = unionSDFs(finalDistance, objectDistance);
            }
            
            if (finalDistance == objectDistance) {
                finalObject = currentObject;
            }
            
            // Set the operation number
            operationNumber = currentObject.objectData[1];
        }
        
        return {
            false,
            finalDistance,
            float3(-1),
            (int)finalObject.objectData[3]
        };
    }
    
    // Scene
    HitInfo sceneSDF(Ray ray) {
        
        // Hold variables
        float distTravelled = 0;
        float dist = 0;
        int itterations = 0;
        HitInfo objectInfo;
        
        // Continue looping until condition met or returned out
        do {
            
            // Calculate the next distance
            objectInfo = getObjectHit(ray);
            dist = objectInfo.dist;
            
            // Add to the distance travled
            distTravelled += dist;
            
            // If the max steps have been passed or the distance traveld is more than the max or dist is less than 0 (shouldn't be possible)
            if (itterations >= this->maxSteps || distTravelled >= this->maxDist || dist < 0.0) {
                
                // Return a false hit
                return {
                    false,
                    distTravelled,
                    
                    ray.origin,
                    
                    0
                };
            }
            
            // March the ray forward
            ray = marchRay(ray, dist);
            
            // Increase itterations
            itterations+=1;
            
        } while (dist > 0.001); // End the do-while loop if the distance is less than epsilon
        
        // Return a true hit
        return {
            true,
            distTravelled,
            
            ray.origin,
            
            objectInfo.materialIndex
        };
    }
    
    // March the ray forward
    Ray marchRay(Ray ray, float dist) {
        return { // Return the new ray with the origin moved
            ray.origin + dist * ray.direction,
            ray.direction
        };
    }
    
    // Coloring
    float3 sceneColoring(float2 uv, float time) {
        
        // Light position
        float3 lightPos = float3(0, 0.7, 1.6);
    
        // Get the hit
        HitInfo hit = sceneSDF(ray);
        
        // If the ray didn't hit
        if (!hit.hit) {
            return float3(0);
        }
        
        // Estimate the normal and calculate the shading
        float3 normal = estimateNormal(ray);
        
        HitInfo shadowRayHit = sceneSDF({
            lightPos,
            normalize(hit.hitPos - lightPos)
        });
        
        if (length(shadowRayHit.hitPos - hit.hitPos) > 0.01) {
            return float3(0);
        }
        
        
        // Thank you: https://learnopengl.com/PBR/Lighting for the help with the bdrf lighting equations & just teaching me how it works
        BDRF bdrf = BDRF();
        
        float3 worldPos = hit.hitPos.xyz;
        float3 N = normal;
        float3 V = -ray.direction;
        float3 L = normalize(lightPos - worldPos);
        float3 H = normalize (V + L);
        
        ObjectMaterial material = scene.materials[hit.materialIndex - 1];
        
        float3 lightColor = float3(50);
        
        // Cook-Torrance BRDF
        float3  F0 = mix (float3 (0.04), pow(material.albedo.xyz, float3(2.2)), material.materialSettings[1]);
        float NDF = bdrf.distributionGGX(N, H, material.materialSettings[0]);
        float G   = bdrf.geometrySmith(N, V, L, material.materialSettings[0]);
        float3  F   = bdrf.fresnelSchlick(max(dot(H, V), 0.0), F0);
        float3  kD  = float3(1.0) - F;
        kD *= 1.0 - material.materialSettings[1];
        
        float3  numerator   = NDF * G * F;
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0);
        float3  specular    = numerator / max(denominator, 0.001);
        
        float NdotL = max(dot(N, L), 0.0);
        
        float3 color = lightColor * (kD * pow(material.albedo.xyz, float3(2.2)) / M_PI_F + specular) *
        (NdotL / dot(lightPos - worldPos, lightPos - worldPos));
        
        
        ray.origin = hit.hitPos + normal * epsilon;
        ray.direction = reflect(ray.direction, normal);
        
        return color;
    }

// MARK: -Public-
public:
    RayMarcher(Ray ray, constant RayTracedScene &scene) {
        this->ray = ray;
        this->scene = scene;
        this->epsilon = 0.005;
        this->maxSteps = 150;
        this->maxDist = 100;
    }
    
    RayMarcher(Ray ray, constant RayTracedScene &scene, float epsilon, int maxSteps, int maxDist) {
        this->ray = ray;
        this->scene = scene;
        this->epsilon = epsilon;
        this->maxSteps = maxSteps;
        this->maxDist = maxDist;
    }
    
    float3 getColor(float2 uv, float time) {
        return sceneColoring(uv, time);
    }
};

half4 fragment fragmentMain(VertexPayload frag [[stage_in]], constant RayTracedScene &scene [[buffer(1)]], constant Uniforms &uniforms [[buffer(2)]]) {
    
    ScreenSize screenSize = uniforms.screenSize;
    float frameNum = uniforms.frameNum;
    
    // Init important constant values
    float2 resolution = float2(screenSize.width, screenSize.height);
    float fieldOfView = 90;
    float aspectRatio = resolution.x / resolution.y; // Calculate the aspect ratio
    
    // Get the UV cordinates and map them to a -1 to 1 space
    float2 uv = ((frag.position.xy / resolution) * 2 - 1);
    uv.y *= -1; // Flip the y cordinate because of how (0, 0) is the top-left corner besides the bottom-left one
    
    // Get the camera distance from the FOV
    float cameraDistance = 1.0f / tan(fieldOfView * 0.5f * 3.14159 / 180.0f); // Get the camer distance from sphere (uses FOV)

    // Apply the aspect ratio to avoid screen stretching
    uv.y /= aspectRatio;
    
    // Create a ray using the uv and camera distance to get the ray directions
    Ray ray = {
        float3(0, 2, -6),
        normalize(float3(uv, cameraDistance))
    };
    
    // Create our ray marcher
    RayMarcher rayMarcher = RayMarcher(ray, scene);
    float3 color = rayMarcher.getColor(uv, frameNum);
    
    
    // Output the final ray's color
    return half4(half3(color), 1.0);
}
