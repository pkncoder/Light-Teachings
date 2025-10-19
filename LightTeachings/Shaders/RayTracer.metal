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
        hit.dist = 9999999999.0;
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
            if (t > 0.0) {
                // Recreate the hit info
                hit.hit = true, // did hit
                
                hit.dist = t, // distance
                
                hit.hitPos = ray.origin + ray.direction * t, // Calculate the final hit position
                hit.normal = normalize((hit.hitPos) - sphere.origin.xyz) * (hit.isInside ? -1.0 : 1.0), // Get the normal
                
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
        hit.dist = 9999999999.0;
        hit.isInside = false;
    
        float3 m = 1./ray.direction;
        float3 n = m*(ray.origin.xyz - box.origin.xyz);
        float3 k = abs(m) * box.bounds.xyz;
    
        float3 t1 = -n - k;
        float3 t2 = -n + k;
    
        float tN = max( max( t1.x, t1.y ), t1.z );
        float tF = min( min( t2.x, t2.y ), t2.z );
    
        if( tN > tF || tF < 0.) return hit;
    
        float t = tN < 0.0 ? tF : tN;
    
        if (t < 0.0) {
            return hit;
        }
    
        hit.hit = true;
        hit.hitPos = ray.origin + ray.direction * t;
        hit.dist = t;
        hit.normal = normalize(-sign(ray.direction)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz)) * (hit.isInside ? -1.0 : 1.0);
        hit.materialIndex = box.objectData[3];
    
        return hit;
    }
    
    // Ray Plane
    //https://www.shadertoy.com/view/4lcSRn
    HitInfoTrace rayPlane(Ray ray, Object plane) {
        
        // Initial hit info
        HitInfoTrace hit;
        hit.hit = false;
        hit.dist = 9999999999.0;
        hit.isInside = false;
        
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
        hit.dist = 9999999999.0;
        hit.materialIndex = (int)cylinder.objectData[3];
        hit.isInside = false;
        
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
        float3 t1 = (boxMin - r.origin) / r.direction;
        float3 t2 = (boxMax - r.origin) / r.direction;
        
        float3 tMin = min(t1, t2);
        float3 tMax = max(t1, t2);
        
        float largestMin = max(max(tMin.x, tMin.y), tMin.z);
        float smallestMax = min(min(tMax.x, tMax.y), tMax.z);
        
        return smallestMax >= largestMin && smallestMax >= 0.0;
    }


    
    HitInfoTrace rayScene(Ray thisRay, bool planesOnly, bool lightTest) {
        
        // Save the final hit info
        HitInfoTrace finalHit;
        finalHit.hit = false;
        finalHit.dist = 999999.0;
        finalHit.isInside = false;
        
        // Save variables for handiling transparent / reflective materials
        bool firstPass = false;
        int loop = -1;
        
        int recursions = 0;
        
        // Current hit info
        HitInfoTrace currentHit;

        // Loop every object
        for (int objectNum = 0; objectNum < scene.renderingData.arrayLengths[0]; objectNum++) {
            
            // Get said object
            Object currentObject = scene.objects[objectNum];
            
            // If this is planes only then skip the not-planes
            if (planesOnly && currentObject.objectData[0] != 5) continue;
            
            // Switch each object based on it's type and get the current hit
            switch((int)currentObject.objectData[0]) {
                    
                case 1: // Sphere
                    currentHit = raySphere(thisRay, currentObject);
                    break;
                case 2:   // Box
                    currentHit = rayBox(thisRay, currentObject);
                    break;
                case 3:   // Rounded Box
                    currentHit = rayBox(thisRay, currentObject);
                    break;
                case 4:   // Outlined Box
                    currentHit = rayBox(thisRay, currentObject);
                    break;
                case 5:   // Plane
                    currentHit = rayPlane(thisRay, currentObject);
                    break;
                case 6:   // Cylinder
                    currentHit = rayCylinder(thisRay, currentObject);
                    break;
                default: // Default
                    currentHit = raySphere(thisRay, currentObject);
                    break;
            }
            
            ObjectMaterial currentMaterial = scene.materials[(int)currentHit.materialIndex - 1];
            
            if ((currentMaterial.transparency[0] == 1.0) && firstPass && !lightTest) {
                
                if (recursions > 5) { // REC_MAX
                    continue;
                }
            
                if (finalHit.isInside || currentObject.objectData[0] == 5) {
                    if (currentObject.objectData[0] != 5) {
                        thisRay = {
                            currentHit.hitPos - currentHit.normal * 0.001,
                            refract(thisRay.direction, currentHit.normal, currentMaterial.transparency[1])
                        };
                    } else {
                        thisRay = {
                            currentHit.hitPos - currentHit.normal * 0.001,
                            refract(thisRay.direction, currentHit.normal, 1.0 / currentMaterial.transparency[1])
                        };
                    }
                    finalHit.isInside = false; // Refraction handeling
                    
                    // Set values for looping
                    loop = -1;
                    objectNum = -1;
                    
                    firstPass = false;
                    
                    // Incraese recurtions
                    recursions += 1;
                    
                } else {
                    thisRay = {
                        currentHit.hitPos - currentHit.normal * 0.001,
                        refract(thisRay.direction, currentHit.normal, 1.0 / currentMaterial.transparency[1])
                    };
                    finalHit.isInside = true; // Refraction Handeling
                    
                    // Set value for the loop
                    objectNum -= 1;
                }
                
                // Default variables at required spots
                currentHit.hit = false;
                finalHit.hit = false;
                finalHit.dist = 999999.0;
                
                // Normalize the direction
                thisRay.direction = normalize(thisRay.direction);
                continue;
            }
            else if (currentMaterial.reflecticity[0] == 1.0 && firstPass && !lightTest) {
                    
                if (recursions > 5) { // REC_MAX
                    continue;
                }
                
                thisRay = {
                    currentHit.hitPos + currentHit.normal * 0.001,
                    normalize(reflect(thisRay.direction, currentHit.normal))
                };
                
                // Set values for looping
                loop = -1;
                objectNum = -1;
                
                firstPass = false;
                
                // Default values at required spots
                finalHit.hit = false;
                finalHit.dist = 999999.0;
                
                // Increase recursion counter
                recursions += 1;
                continue;
            }
            else if ((currentMaterial.transparency[0] == 1.0 || currentMaterial.reflecticity[0] == 1.0) && (currentHit.hit && finalHit.dist > currentHit.dist)) {
                loop = objectNum;
            }
            
            // If the current object was a hit AND is the closest to the camera then set it as the final hit
            if (currentHit.hit && finalHit.dist > currentHit.dist) {
                finalHit = currentHit;
            }
            
            if ((objectNum + 1 == scene.renderingData.arrayLengths[0]) && (loop != -1)) {
                firstPass = true;
            
                if (((scene.materials[finalHit.materialIndex - 1].transparency[0] == 1 || scene.materials[finalHit.materialIndex - 1].reflecticity[0] == 1) && !lightTest) && recursions <= 5) { // REC_MAX
                    objectNum = loop - 1;
                    continue;
                }
            }
            
            
        }

        finalHit.outRay = thisRay;
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
        ray = hit.outRay;
        
        // Save the light color and the ambient color
        Light light = scene.light;
        float3 ambient = scene.renderingData.ambient.xyz * scene.renderingData.ambient.w * light.albedo.xyz * scene.materials[hit.materialIndex - 1].albedo.xyz;

        // Test to see if shadows are enabled
        if (modelinator.shadows) {
            
            // If it is create a shadow ray and get the hit info
            Ray shadowRay = {
                hit.hitPos + hit.normal * 0.001,
                normalize(light.origin.xyz - hit.hitPos)
            };
            Ray cpy = shadowRay;
            HitInfoTrace shadowRayHit = rayScene(shadowRay, false, true);
            shadowRay = shadowRayHit.outRay;
            // Test to see if the shadow ray hit anything and that it is in between the light and the shadow ray's origin
            if (hit.hit && shadowRayHit.hit && (length(shadowRayHit.hitPos - cpy.origin.xyz) < length(cpy.origin.xyz - light.origin.xyz)) && !(scene.materials[shadowRayHit.materialIndex-1].transparency[0] == 1.0)) {
                return SRGB::LinearToSRGB(ToneMapping::ACESFilm(ambient)); // Return the ambient color since the hit is in shadow
            }
        }
        
        float3 color;
        if (hit.hit && !(scene.materials[hit.materialIndex-1].transparency[0] == 1.0 || scene.materials[hit.materialIndex-1].reflecticity[0] == 1.0)) {
            // Get the color from the modelinator
            color = modelinator.color(ray, hit, scene);
        } else {
            
            color = scene.renderingData.shadingInfo[3] ? getSkyColor(ray) : float3(0.0);
        }
        
        // Tone mapping and SRGB
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
