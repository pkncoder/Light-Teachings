#include "./Modelinator.metal"

#include "./SRGB.metal"
#include "./ToneMapping.metal"

using namespace metal;

// Ray Traced Shader function
class RayTracer {
// MARK: -Private-
private:
    
    // Attrs
    Ray ray;
    RayTracedScene scene;

    
    
    /* MARK: -RAY INTERCEPTIONS- */
    
    // Ray Sphere
    HitInfoTrace raySphere(Ray ray, Object sphere) {
        
        // Initial hit info
        HitInfoTrace hit;
        hit.hit = false;
        hit.dist = 99999.0;
        hit.isInside = false;

        float3 oc = ray.origin - sphere.origin.xyz; // Pos of sphere
        float a = dot(ray.direction, ray.direction); // A of the quadradic formula
        float b = dot(oc, ray.direction); // B of the quadradic formula
        float c = dot(oc, oc) - sphere.bounds[3] * sphere.bounds[3]; // C of the quadradic formula
        
        float discriminant = b * b - a * c; // Descriminant
    
        if (discriminant > 0.0f) { // If the ray hit anything (<0 no hit, =0 one interception, <0 two interceptions)
            
            float t = (-b - sqrt(discriminant)) / a; // Calculate the distance
            
            // If that was negitive, then try the other choice in the quadradic formula
            if(t < 0) {
                t = (-b + sqrt(discriminant)) / a;
                hit.isInside = true;
            }
            
            // If the ray is still greater than 0, and long enough that the ray didn't hit the same sphere it started on
            if (t > 0.01) {
                // Recreate the hit info
                hit.hit = true, // did hit
                
                hit.dist = t, // distance
                
                hit.hitPos = ray.origin + ray.direction * t, // Calculate the final hit position
                hit.normal = normalize((ray.origin + ray.direction * t) - sphere.origin.xyz) * (hit.isInside ? -1.0 : 1.0), // Get the normal
                
                hit.materialIndex = (int)sphere.objectData[3]; // Pass through the sphere's material
            }
        }
        
        // Return the final hit info
        return hit;
    }
    
    // Ray Box
    // (no idea where I found this to be honest, it floats around)
    HitInfoTrace rayBox( Ray ray, Object box ) {
    
        // Inital hit info
        HitInfoTrace hit;
        hit.hit = false;
        hit.dist = 99999.0;
    
        float3 m = 1./ray.direction;
        float3 n = m*(ray.origin.xyz - box.origin.xyz);
        float3 k = abs(m) * box.bounds.xyz;
    
        float3 t1 = -n - k;
        float3 t2 = -n + k;
    
        float tN = max( max( t1.x, t1.y ), t1.z );
        float tF = min( min( t2.x, t2.y ), t2.z );
    
        if( tN > tF || tF < 0.) return hit;
    
        float t = tN < 0.1 ? tF : tN;
    
        if (t < 0.01) {
            return hit;
        }
    
        hit.hit = true;
        hit.hitPos = ray.origin + ray.direction * t;
        hit.dist = t;
        hit.normal = -sign(ray.direction)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz);
        hit.materialIndex = box.objectData[3];
    
        return hit;
    }
    
    // Ray Plane
    //https://www.shadertoy.com/view/4lcSRn
    HitInfoTrace rayPlane(Ray ray, Object plane) {
        
        // Initial hit info
        HitInfoTrace hit;
        hit.hit = false;
        hit.dist = 99999.0;
        
        // Figure out if the ray is pointing towards the plane enough to hit it
        float denom = dot(plane.bounds.xyz, ray.direction);
        if (abs(denom) > 0.0001f)
        {
            // If it is then get the distance
            float t = dot((float3(0.0, plane.origin.w, 0.0) - ray.origin), plane.bounds.xyz) / denom;
            if (t < 0) return hit; // Double check for negative distance
            
            // Modify hit info
            hit.hit = true;
            hit.dist = t;
            hit.hitPos = ray.origin + ray.direction * t;
            hit.normal = plane.bounds.xyz;
            hit.materialIndex = (int)plane.objectData[3];
        }
        
        // Return the final hit info
        return hit;
    }
    
    // Ray Cylinder
    // https://iquilezles.org/articles/intersectors/
    HitInfoTrace rayCylinder( Ray ray, Object cylinder )
    {
        
        // Save the inital hit info
        HitInfoTrace hit;
        hit.hit = false;
        hit.dist = 99999.0;
        hit.materialIndex = (int)cylinder.objectData[3];
        
        // Get the normalized normal of the cylinder
        float3 normal = normalize(cylinder.bounds.xyz);
        
        // Caps of the cylinders
        float3 pa = cylinder.origin.xyz + normal * cylinder.origin.w;
        float3 pb = cylinder.origin.xyz - normal * cylinder.origin.w;
        float ra = cylinder.bounds.w;
        
        float3  ba = pb - pa;
        float3  oc = ray.origin - pa;

        float baba = dot(ba,ba);
        float bard = dot(ba,ray.direction);
        float baoc = dot(ba,oc);
        
        float k2 = baba            - bard*bard;
        float k1 = baba*dot(oc,ray.direction) - baoc*bard;
        float k0 = baba*dot(oc,oc) - baoc*baoc - ra*ra*baba;
        
        float h = k1*k1 - k2*k0;
        if( h<0.0 ) return hit;
        h = sqrt(h);
        float t = (-k1-h)/k2;

        // body
        float y = baoc + t*bard;
        if( y>0.0 && y<baba && t > 0.0 && t < hit.dist ) {
            hit.hit = true;
            hit.dist = t;
            hit.normal = (oc+t*ray.direction - ba*y/baba)/ra;
        }
        
        // caps
        t = ( ((y<0.0) ? 0.0 : baba) - baoc)/bard;
        if(t > 0.0 && t < hit.dist &&  abs(k1+k2*t)<h ) {
            hit.hit = true;
            hit.dist = t;
            hit.normal = ba*sign(y)/sqrt(baba);
        }
        
        hit.hitPos = ray.origin + ray.direction * hit.dist;
        

        return hit;
    }
    
    // Bounding Box
    bool rayBBox(const float3 boxMin, const float3 boxMax, const Ray r) {
        float3 t1 = (boxMin - ray.origin) / ray.direction;
        float3 t2 = (boxMax - ray.origin) / ray.direction;
        
        float3 tMin = min(t1, t2);
        float3 tMax = max(t1, t2);
        
        float largestMin = max(max(tMin.x, tMin.y), tMin.z);
        float smallestMax = min(min(tMax.x, tMax.y), tMax.z);
        
        return smallestMax >= largestMin && smallestMax >= 0.0;
    }


    
    HitInfoTrace rayScene(Ray ray, bool planesOnly, bool lightTest) {
        
        // Save the final hit info
        HitInfoTrace finalHit;
        finalHit.hit = false;
        finalHit.dist = 999999999999.0;
        finalHit.isInside = false;
        
        bool firstPass = false;
            
        int recursions = 0;
        
        int loop = -1;
        int skip = -1;

        // Loop every object
        for (int objectNum = 0; objectNum < scene.renderingData.arrayLengths[0]; objectNum++) {
            
            if (objectNum == skip) {
                continue;
            }
            
            // Get said object
            Object currentObject = scene.objects[objectNum];
            
            // If this is planes only then skip the not-planes
            if (planesOnly && currentObject.objectData[0] != 5) continue;
            
            // Current hit info
            HitInfoTrace currentHit;
            
            // Switch each object based on it's type and get the current hit
            switch((int)currentObject.objectData[0]) {
                    
                case 1: // Sphere
                    currentHit = raySphere(ray, currentObject);
                    break;
                case 2:   // Box
                    currentHit = rayBox(ray, currentObject);
                    break;
                case 3:   // Rounded Box
                    currentHit = rayBox(ray, currentObject);
                    break;
                case 4:   // Outlined Box
                    currentHit = rayBox(ray, currentObject);
                    break;
                case 5:   // Plane
                    currentHit = rayPlane(ray, currentObject);
                    break;
                case 6:   // Cylinder
                    currentHit = rayCylinder(ray, currentObject);
                    break;
                default: // Default
                    currentHit = raySphere(ray, currentObject);
                    break;
            }
            
            ObjectMaterial currentMaterial = scene.materials[currentHit.materialIndex - 1];
            
            if ((currentMaterial.transparency[0] == 1.0) && firstPass && !lightTest) {
            
                if (recursions > 3) { // REC_MAX
                    continue;
                }
            
                if (finalHit.isInside || currentObject.objectData[0] == 5) {
                
                    if (currentObject.objectData[0] != 5) {
                        ray = {
                            currentHit.hitPos - currentHit.normal * 0.01,
                            refract(ray.direction, currentHit.normal, currentMaterial.transparency[1])
                        };
                    } else {
                        ray = {
                            currentHit.hitPos - currentHit.normal * 0.01,
                            refract(ray.direction, currentHit.normal, 1.0 / currentMaterial.transparency[1])
                        };
                    }
                    
                    finalHit.isInside = false;
                    
                    skip = objectNum;
                    objectNum = -1;
                    
                    loop = -1;
                    
                    recursions += 1;
                    
                } else {
                    ray = {
                        currentHit.hitPos - currentHit.normal * 0.01,
                        refract(ray.direction, currentHit.normal, 1.0 / currentMaterial.transparency[1])
                    };
                    finalHit.isInside = true;
                    
                    skip = -1;
                    objectNum -= 1;
                }
                
                
                
                ray.direction = normalize(ray.direction);
                continue;
            }
            else if (currentMaterial.reflecticity[0] == 1.0 && firstPass && !lightTest) {
                    
                if (recursions > 3) { // REC_MAX
                    continue;
                }
                
                ray = {
                    currentHit.hitPos + currentHit.normal * 0.01,
                    normalize(reflect(ray.direction, currentHit.normal))
                };
                
                loop = -1;
                
                skip = objectNum;
                objectNum = -1;
                
                recursions += 1;
                
                finalHit.hit = true;
                finalHit.dist = 999999.0;
                
                continue;
            }
            else if ((currentMaterial.transparency[0] == 1.0 || currentMaterial.reflecticity[0] == 1.0) && (currentHit.hit && finalHit.dist > currentHit.dist)) {
                loop = objectNum;
            }
            
            // If the current object was a hit AND is the closest to the camera then set it as the final hit
            finalHit = (finalHit.dist < currentHit.dist) ? finalHit : currentHit;
            
            if ((objectNum + 1 == scene.renderingData.arrayLengths[0]) && (loop != -1)) {
                firstPass = true;
            
                if (((scene.materials[finalHit.materialIndex - 1].transparency[0] == 1 || scene.materials[finalHit.materialIndex - 1].reflecticity[0] == 1) && !lightTest) && recursions <= 3) { // REC_MAX
                    objectNum = loop - 1;
                    continue;
                }
            }
            
            
        }

        finalHit.outRay = ray;
        // Return the final found hit
        return finalHit;
    }
    
    
    
    /* Coloring */
    
    // Sky coloring
    float3 getSkyColor(Ray ray) {
        return mix(float3(0.8, 0.4, 0.0), float3(0.1, 0.4, 0.5), sin(dot(float3(0.0, 1.0, 0.0), ray.direction) + 0.5));
    }
    
    // Full SceneColoring
    float3 sceneColoring(float2 uv, Modelinator modelinator) {

        // Test to see if we hit the bounding box around the non-inf objects
        bool boundingBoxMiss = !rayBBox(scene.topBoundingBox.boxMin.xyz, scene.topBoundingBox.boxMax.xyz, ray);
        
        // Get the scene hit
        HitInfoTrace hit = rayScene(ray, boundingBoxMiss, false);
        
        // Save the light color and the ambient color
        Light light = scene.light;
        float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * light.albedo.xyz * scene.materials[hit.materialIndex - 1].albedo.xyz;

        // Test to see if shadows are enabled
        if (modelinator.shadows && !(scene.materials[hit.materialIndex-1].transparency[0] == 1.0 || scene.materials[hit.materialIndex-1].reflecticity[0] == 1.0)) {
            
            if (hit.hit && hit.dist > 0.0) {
                // If it is create a shadow ray and get the hit info
                Ray shadowRay = {
                    hit.hitPos + hit.normal * 0.01,
                    normalize(light.origin.xyz - hit.hitPos)
                };
                HitInfoTrace shadowRayHit = rayScene(shadowRay, false, true);
                
                // Test to see if the shadow ray hit anything and that it is in between the light and the shadow ray's origin
                if (shadowRayHit.hit && (length(shadowRayHit.hitPos - shadowRay.origin.xyz) < length(shadowRay.origin.xyz - light.origin.xyz)) && !(scene.materials[shadowRayHit.materialIndex-1].transparency[0] == 1.0)) {
                    return SRGB::LinearToSRGB(ToneMapping::ACESFilm(ambient)); // Return the ambient color since the hit is in shadow
                }
            }
        }
        
        // If we don't hit anything return sky color
        if (!hit.hit || (scene.materials[hit.materialIndex-1].transparency[0] == 1.0) || scene.materials[hit.materialIndex-1].reflecticity[0] == 1.0) {
            return (scene.renderingData.shadingInfo[3] == 1) ? SRGB::LinearToSRGB(ToneMapping::ACESFilm(getSkyColor(hit.outRay))) : float3(0.0);
        }
        
        // Get the color from the modelinator
        float3 color = modelinator.color(ray, hit, light.origin.xyz, hit.normal, scene);
        
        // Tone mapping and srgb
        color = SRGB::LinearToSRGB(ToneMapping::ACESFilm(color));
        
        // Return the final color
        return color;
    }

// MARK: -Public-
public:
    // Constructor
    RayTracer(Ray ray, constant RayTracedScene &scene) {
        this->ray = ray;
        this->scene = scene;
    }

    // Public get color function
    float3 getColor(float2 uv, Modelinator modelinator) {
        return sceneColoring(uv, modelinator);
    }
};
