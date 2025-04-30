////
////  tracedShaders.metal
////  SimpleRayTracer
////
////  Created by Kia Preston on 4/27/25.
////
//
//#include "LightTeachings-Bridging-Header.h"
//#include <metal_stdlib>
//using namespace metal;
//
//struct VertexPayload {              //Mesh Vertex Type
//    float4 position [[position]];   //Qualified attribute
//    half3 color;                    //Half precision, faster
//    
//    /*
//     See the metal spec, page 68, table 2.11: Mesh Vertex Attributes
//     For more builtin variables we can set besides position.
//    */
//};
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
///* ----------- Random Numbers ----------- */
//
//// Wang hash alg
//uint wang_hash(uint seed) {
//    uint state = seed * 747796405u + 2891336453u;
//    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
//    seed = (word >> 22u) ^ word;
//    return seed;
//}
//
//// Random float from 0.0000 to 1.0000000...
//// Returns the state in the 2'nd pos in the vector
//float2 RandomFloat01(uint state) {
//    state = wang_hash(state);
//    return float2(float(state) / 4294967296.0, state);
//}
//
//// Random normalized vector in x y z
//// Returns the state in the 4'th pos in the vector
//float4 RandomUnitVector(uint state) {
//
//    float2 randOne = RandomFloat01(state);
//    state = uint(randOne.y);
//    float2 randTwo = RandomFloat01(state);
//    state = uint(randTwo.y);
//
//    float z =  randOne.x * 2.0f - 1.0f;
//    float a = randTwo.x * 6.28318530718;
//    float r = sqrt(1.0f - z * z);
//    float x = r * cos(a);
//    float y = r * sin(a);
//    return float4(x, y, z, state);
//}
//
//
//
///* ----------- Interception Functions ----------- */
//
//// Ray - Sphere interception
//RayTracedHitInfo interceptSphere(Ray ray, Object sphere) {
//
//    // Maths
//    float3 oc = ray.origin - sphere.origin.xyz; // Pos of sphere
//    float a = dot(ray.direction, ray.direction); // A of the quadradic formula
//    float b = dot(oc, ray.direction); // B of the quadradic formula
//    float c = dot(oc, oc) - sphere.bounds[3] * sphere.bounds[3]; // C of the quadradic formula
//
//    float discriminant = b * b - a * c; // Descriminant
//
//    if (discriminant > 0.0f) { // If the ray hit anything (<0 no hit, =0 one interception, <0 two interceptions)
//
//        float t = (-b - sqrt(discriminant)) / a; // Calculate the distance
//
//        // If that was negitive, then try the other choice in the quadradic formula
//        if(t < 0) {
//            t = (-b + sqrt(discriminant)) / a;
//        }
//
//        // If the ray is still greater than 0, and long enough that the ray didn't hit the same sphere it started on
//        if (t > 0.01) {
//            // Recreate the hit info
//            return RayTracedHitInfo {
//                t, // Distance
//
//                true, // Did hit
//
//                float4(ray.origin + ray.direction * t,0), // Calculate the final hit position
//                float4(normalize((ray.origin + ray.direction * t) - sphere.origin.xyz), 0), // Get the normal, reverse if inside it'self
//
//                sphere.objectData[3] // Pass through the sphere's material
//            };
//        }
//    }
//    
//    return RayTracedHitInfo {
//        99999999.0,
//        
//        false,
//        
//        float4(0),
//        float4(-1),
//        
//        -1.0
//    };
//}
//
//// Ray - Sphere interception
//// TODO: Find creator of this function or code own
//// TODO: Find out how the math works
//// TODO: Create the fromInside capibilities
//RayTracedHitInfo interceptBox( Ray ray, Object box ) {
//
//    // Start hit info (not hit)
//    RayTracedHitInfo hit;
//    hit.dist = 9999999.0;
//    hit.hit = false;
//
//    float3 m = 1./ray.direction;
//    float3 n = m*(ray.origin.xyz - box.origin.xyz);
//    float3 k = abs(m) * box.bounds.xyz;
//
//    float3 t1 = -n - k;
//    float3 t2 = -n + k;
//
//    float tN = max( max( t1.x, t1.y ), t1.z );
//    float tF = min( min( t2.x, t2.y ), t2.z );
//
//    if( tN > tF || tF < 0.) return hit;
//
//    float t = tN < 0.1 ? tF : tN;
//
//    if (t < 0.01) {
//        return hit;
//    }
//
//    hit.hit = true;
//    hit.hitPos = float4(ray.origin + ray.direction * t, 0);
//    hit.dist = t;
//    hit.normal = float4(-sign(ray.direction)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz), 0);
//    hit.materialIndex = box.objectData[3];
//
//    return hit;
//}
//
//
//
///* ----------- Path Tracing Functions ----------- */
//
//// https://www.shadertoy.com/view/ttfyzN ; buffer A ; line 149 ; date now: 1.19.25
//// Used to find how reflective an object is using fresnel law
//float FresnelReflectAmount(float n1, float n2, float3 normal, float3 incident, float f0, float f90)
//{
//    // Schlick aproximation
//    float r0 = (n1-n2) / (n1+n2);
//    r0 *= r0;
//    float cosX = -dot(normal, incident);
//    if (n1 > n2)
//    {
//        float n = n1/n2;
//        float sinT2 = n*n*(1.0-cosX*cosX);
//        // Total internal reflection
//        if (sinT2 > 1.0)
//            return f90;
//        cosX = sqrt(1.0-sinT2);
//    }
//    float x = 1.0-cosX;
//    float ret = r0+(1.0-r0)*x*x*x*x*x;
//
//    // adjust reflect multiplier for object reflectivity
//    return mix(f0, f90, ret);
//}
//
//// Find the closest hit in the scene
//RayTracedHitInfo map(Ray ray, RayTracedScene scene) {
//
//    // Define the current closest hit
//    RayTracedHitInfo closestHit;
//    closestHit.dist = 999999999.0; // Large enough for other functions to override
//    closestHit.hit = false;
//    closestHit.hitPos = float4(0);
//
//    // Loop every sphere in scene
//    for (int i = 0; i < scene.lengths[0]; i++) {
//        
//        Object currentObject = scene.objects[i];
//        
//        RayTracedHitInfo hit;
//        
//        if (currentObject.objectData[0] == 0) {
//            hit = interceptSphere(ray, currentObject); // Get the hit from interception function
//        } else if (currentObject.objectData[0] == 1) {
//            hit = interceptBox(ray, currentObject);
//        } else {
//            interceptSphere(ray, currentObject); // Get the hit from interception function
//        }
//
//        if (hit.hit && (hit.dist < closestHit.dist)) { // If that ray did hit, and is closer than the current closest hit, set it as the newest closest hit
//            closestHit = hit;
//        }
//    }
//
//    // Return the closest hit
//    return closestHit;
//}
//
//// Path trace the scene
//float3 pathTrace(Ray ray, float2 uv, uint rngState, int bounces, RayTracedScene scene) {
//
//    // Get the starter colors
//    float3 color = float3(0.0); // The final return color
//    float3 colorMult = float3(1.0); // The color that the ray accumulated from bouncing around
//
//    for (int bounceIndex = 0; bounceIndex <= bounces; ++bounceIndex)
//    {
//        // Send a ray out into the world
//        RayTracedHitInfo hit = map(ray, scene);
////        return hit.hitPos.xyz;
//        // if the ray missed, we are done
//        if (!hit.hit)
//            break;
//
//        // Save the specular and refractive chances to be modified
//        float3 albedo = scene.materials[(int)hit.materialIndex].color.xyz;
//        float3 emmisive = scene.materials[(int)hit.materialIndex].emmisive.xyz * scene.materials[(int)hit.materialIndex].emmisive.w;
//        
//        float3 specularColor = scene.materials[(int)hit.materialIndex].specularColor.xyz;
//        float specularChance = scene.materials[(int)hit.materialIndex].materialSettings.x;
//        float specularRoughness = scene.materials[(int)hit.materialIndex].materialSettings.y;
////        float refractionChance = hit.material.refractiveChance;
//
//        ray.origin = hit.hitPos.xyz + hit.normal.xyz * 0.01; // Else, move it a bit off of the sphere with the normal
//
//        // Get two random directions
//        float4 randDir = RandomUnitVector(rngState);
//        rngState = uint(randDir.w);
//        float2 doSpecular = RandomFloat01(rngState);
//        rngState = uint(doSpecular.y);
//
//        // Use one for the diffuse ray direction, weight the ray towards the normal (cosine weighted hemisphere sampling)
//        float3 diffuse = normalize(hit.normal.xyz + randDir.xyz);
//
//        // Reflect against the normal to get the specular portion, then modify it based on the specular roughness
//        float3 specular = reflect(ray.direction.xyz, hit.normal.xyz);
//        specular = normalize(mix(specular, diffuse, specularRoughness * specularRoughness));
//
//        // Get the final ray direction
//        ray.direction = mix(diffuse, specular, doSpecular.x);
//
//        // Add to the final color with the material's emmisive value times the color multiplication
//        color += emmisive * colorMult;
//
//        // As long as the ray isn't refractive, modify the color multiplication with the matierial's color
//        // If the material is refractive, than absorbtion will take place at the start of the function
////        if (doRefraction == 0.0f)
//        colorMult *= mix(albedo, specularColor, doSpecular.x);
//
//        // Devide the color multiplication by the ray probibility
////        colorMult /= rayProbability;
//
//        float p = max(colorMult.x, max(colorMult.y, colorMult.z));
//        float2 randomNum = RandomFloat01(rngState);
//        rngState = randomNum.y;
//
//        if (randomNum.x > p)
//            break;
//
//        colorMult /= p;
//    }
//
//    // return pixel color
//    return color;
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//half4 fragment fragmentPathTracer(VertexPayload frag [[stage_in]], constant RayTracedScene &scene [[buffer(1)]], constant Uniforms &uniforms [[buffer(2)]]) {
//    
//    ScreenSize screenSize = uniforms.screenSize;
//    float frameNum = uniforms.frameNum;
//    
//    // Init important constant values
//    float2 resolution = float2(screenSize.width, screenSize.height);
//    float fieldOfView = 90;
//    float aspectRatio = resolution.x / resolution.y; // Calculate the aspect ratio
//    
//    // Get the UV cordinates and map them to a -1 to 1 space
//    float2 uv = ((frag.position.xy / resolution) * 2 - 1);
//    uv.y *= -1; // Flip the y cordinate because of how (0, 0) is the top-left corner besides the bottom-left one
//    
//    // Get the camera distance from the FOV
//    float cameraDistance = 1.0f / tan(fieldOfView * 0.5f * 3.14159 / 180.0f); // Get the camer distance from sphere (uses FOV)
//
//    // Apply the aspect ratio to avoid screen stretching
//    uv.y /= aspectRatio;
//    
//    // Create a ray using the uv and camera distance to get the ray directions
//    Ray ray = {
//        float3(0, 0, -4),
//        normalize(float3(uv, cameraDistance))
//    };
//    
//    uint rngState = uint(uint(frag.position.x) * uint(1973) + uint(frag.position.y) * uint(9277) + uint(frameNum * 4315.143155432) * uint(26699)) | uint(1);
//    
//    float3 color = float3(0);
//    // Create our ray marcher
//    for (int i = 0; i < 8; i++) {
//        rngState += uint(i);
//        color += pathTrace(ray, uv, rngState, 8, scene);
//    }
//    
//    
//    // Output the final ray's color
//    return half4(half3(color/8.0), 1.0);
//}
