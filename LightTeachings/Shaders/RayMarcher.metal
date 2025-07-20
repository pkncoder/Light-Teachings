//#include "../LightTeachings-Bridging-Header.h"
#include <metal_stdlib>

#include "./Modelinator.metal"

using namespace metal;

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

    // Bounding Box
    bool BBoxIntersect(const float3 boxMin, const float3 boxMax, const Ray r) {
        float3 t1 = (boxMin - ray.origin) / ray.direction;
        float3 t2 = (boxMax - ray.origin) / ray.direction;
        
        float3 tMin = min(t1, t2);
        float3 tMax = max(t1, t2);
        
        float largestMin = max(max(tMin.x, tMin.y), tMin.z);
        float smallestMax = min(min(tMax.x, tMax.y), tMax.z);
        
        return smallestMax >= largestMin && smallestMax >= 0.0;
    }


    // MARK: -Object Functions-

    // Lightings
    float3 estimateNormal(Ray ray) {

        // Get the normal ray hit
        HitInfo rayHit = sceneSDF(ray, false);

        // Get the new rays with epsilon modifications
        Ray rayPOne = {ray.origin + float3(epsilon, 0, 0), ray.direction};
        Ray rayPTwo = {ray.origin + float3(0, epsilon, 0), ray.direction};
        Ray rayPThree = {ray.origin + float3(0, 0, epsilon), ray.direction};

        // Estimate the final normal
        return normalize(float3(
            sceneSDF(rayPOne, false).dist - rayHit.dist,
            sceneSDF(rayPTwo, false).dist - rayHit.dist,
            sceneSDF(rayPThree, false).dist - rayHit.dist
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

    HitInfo getObjectHit(Ray ray, bool planesOnly) {

        // Declare variables
        float finalDistance = -1.0; // Initialized to -1.0 for the start
        float objectDistance;
        float operationNumber;
        Object finalObject = scene.objects[0];

        // Loop every object
        for (int objectNum = 0; objectNum < scene.renderingData.arrayLengths[0]; objectNum++) {

            // Get said object
            Object currentObject = scene.objects[objectNum];
            
            if (planesOnly && currentObject.objectData[0] != 5) { continue; }

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
    HitInfo sceneSDF(Ray ray, bool planeOnly) {

        // Hold variables
        float distTravelled = 0;
        float dist = 0;
        int itterations = 0;
        HitInfo objectInfo;

        // Continue looping until condition met or returned out
        do {

            // Calculate the next distance
            objectInfo = getObjectHit(ray, planeOnly);
            
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
    float3 sceneColoring(float2 uv, float doIt, Modelinator modelinator) {

        // Light position
        float3 lightPos = float3(0, 0.7, 1.6);

        bool objectsHit = !BBoxIntersect(scene.topBoundingBox.boxMin.xyz, scene.topBoundingBox.boxMax.xyz, ray);

//        if (doIt > 0.0) {
//            return float3(!objectsHit);
//        }

        // Get the hit
        HitInfo hit = sceneSDF(ray, objectsHit);

        // If the ray didn't hit
        if (!hit.hit) {
            return float3(0);
        }

        // Estimate the normal and calculate the shading
        float3 normal = estimateNormal(ray);

        HitInfo shadowRayHit = sceneSDF({
            lightPos,
            normalize(hit.hitPos - lightPos)
        },false);

        if (length(shadowRayHit.hitPos - hit.hitPos) > 0.01) {
            return float3(0);
        }

        float3 color = modelinator.color(ray, hit, lightPos, normal, scene);

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

    float3 getColor(float2 uv, float time, Modelinator modelinator) {
        return sceneColoring(uv, time, modelinator);
    }
};
