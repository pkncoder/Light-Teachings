//
//  shaders.metal
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

#include "SimpleRayTracer-Bridging-Header.h"
#include <metal_stdlib>
using namespace metal;

struct VertexPayload {              //Mesh Vertex Type
    float4 position [[position]];   //Qualified attribute
    half3 color;                    //Half precision, faster
    
    /*
     See the metal spec, page 68, table 2.11: Mesh Vertex Attributes
     For more builtin variables we can set besides position.
    */
};

constant float4 positions[] = {
    float4(-1.0, -1.0, 0.0, 1.0), //bottom left: red
    float4( 1.0, -1.0, 0.0, 1.0), //bottom right: green
    float4(  1.0, 1.0, 0.0, 1.0), //center top: blue
    float4( -1.0, 1.0, 0.0, 1.0)
};

/*
    The vertex qualifier registers this function in the vertex stage of the Metal API.
    
    Currently we're just taking the Vertex ID, it'll be reset at the start of the draw call
    and increment for each successive invocation.
    
    See page 99 of the metal spec,
    table 5.2: Attributes for vertex function input arguments,
    for more info.
*/
VertexPayload vertex vertexMain(uint vertexID [[vertex_id]]) {
    VertexPayload payload;
    payload.position = positions[vertexID];
    return payload;
}


class RayMarcher {
// MARK: -Private-
private:
    Ray ray;
    RayTracedScene scene;
    
    float epsilon;
    float maxSteps;
    float maxDist;
    
    // MARK: -Object SDFs-
    
    // Sphere
    float sphereSDF(Ray ray, Object sphere) {
        return length(sphere.origin.xyz - ray.origin) - sphere.bounds.x;
    }
    
    // Box
    float boxSDF(Ray ray, Object box)
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
        float3 p = abs(ray.origin)-box.bounds.xyz;
        float3 q = abs(p+box.bounds.w)-box.bounds.w;
        return min(min(
          length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
          length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
          length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
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
    
    float getDistance(Ray ray) {
        
        // differenceSDFs(boxSDF(ray, scene.objects[0]), roundedBoxSDF(ray, scene.objects[1]));
        
        // Declare variables
        float finalDistance = -1.0; // Initialized to -1.0 for the start
        float objectDistance;
        float operationNumber = 0;
        
        // Loop every object
        for (int objectNum = 0; objectNum < scene.lengths[0]; objectNum++) {
            
            // Get said object
            Object object = scene.objects[objectNum];
            
            
            // Get this object distance
            if (object.data[0] == 1) {          // Sphere
                objectDistance = sphereSDF(ray, object);
            } else if (object.data[0] == 2) {   // Box
                objectDistance = boxSDF(ray, object);
            } else if (object.data[0] == 3) {   // Rounded Box
                objectDistance = roundedBoxSDF(ray, object);
            } else if (object.data[0] == 4) {   // Outlined Box
                objectDistance = outlinedBoxSDF(ray, object);
            } else {                            // Default
                objectDistance = sphereSDF(ray, object);
            }
            
            
            // Perform any opperations
            
            // If there is no previous distance held
            if (finalDistance == -1.0) {
                
                // Set the object distance to the final one
                finalDistance = objectDistance;
                
                // Set the operation number
                operationNumber = object.data[1];
                
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
            
            // Set the operation number
            operationNumber = object.data[1];
        }
        
        return finalDistance;
    }
    
    // Scene
    HitInfo sceneSDF(Ray ray) {
        
        // Hold variables
        float distTravelled = 0;
        float dist = 0;
        int itterations = 0;
        
        // Continue looping until condition met or returned out
        do {
            
            // Calculate the next distance
            dist = getDistance(ray);
            
            // Add to the distance travled
            distTravelled += dist;
            
            // If the max steps have been passed or the distance traveld is more than the max or dist is less than 0 (shouldn't be possible)
            if (itterations >= this->maxSteps || distTravelled >= this->maxDist || dist < 0.0) {
                
                // Return a false hit
                return {
                    false,
                    distTravelled,
                    
                    ray.origin
                };
            }
            
            // March the ray forward
            ray = marchRay(ray, dist);
            
            // Increase itterations
            itterations+=1;
            
        } while (dist > 0.01); // End the do-while loop if the distance is less than epsilon
        
        // Return a true hit
        return {
            true,
            distTravelled,
            
            ray.origin
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
    float3 sceneColoring() {
        
        // HitInfo { float dist, bool hit, float3 hitPos }
        // Ray { float3 origin, float3 direction }
        
        // Light position
        float3 lightPos = float3(0, 3, 0);
        
        // Get the hit
        HitInfo hit = sceneSDF(ray);
        
        // If the ray didn't hit
        if (!hit.hit) {
            return float3(0);
        }
        
        // Estimate the normal and calculate the shading
        float3 normal = estimateNormal(ray);
        
        HitInfo shadowRay = sceneSDF({
            hit.hitPos + normal * 0.1,
            normalize(lightPos - (hit.hitPos + normal * 0.001))
        });
        
        if (shadowRay.dist < (length(lightPos - (hit.hitPos + normal * 0.01)))) {
            return float3(0);
        }
        
        float shading = max(dot(normal, normalize(lightPos - (hit.hitPos + normal * epsilon))), 0.0);
        
        // Return the final value with using the inverse square law
        return (float3(1) * shading * 50.0) * (1 / pow(length(lightPos - hit.hitPos), 2.0));
    }

// MARK: -Public-
public:
    RayMarcher(Ray ray, constant RayTracedScene &scene) {
        this->ray = ray;
        this->scene = scene;
        this->epsilon = 0.001;
        this->maxSteps = 100;
        this->maxDist = 100;
    }
    
    RayMarcher(Ray ray, constant RayTracedScene &scene, float epsilon, int maxSteps, int maxDist) {
        this->ray = ray;
        this->scene = scene;
        this->epsilon = epsilon;
        this->maxSteps = maxSteps;
        this->maxDist = maxDist;
    }
    
    float3 getColor() {
//        float dist = sceneSDF(this->ray);
        return sceneColoring();
    }
};

half4 fragment fragmentMain(VertexPayload frag [[stage_in]], constant ScreenSize &screenSize [[buffer(1)]], constant RayTracedScene &scene [[buffer(2)]]) {
    
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
        float3(0, 0, -8),
        normalize(float3(uv, cameraDistance))
    };
    
    // Create our ray marcher
    RayMarcher rayMarcher = RayMarcher(ray, scene);
    float3 color = rayMarcher.getColor();
    
    
    // Output the final ray's color
    return half4(half3(color), 1.0);
}
