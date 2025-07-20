#include <metal_stdlib>

#include "./Models/BDRF.metal"
#include "./Models/SimpleShading.metal"
#include "./Models/Hit.metal"
#include "./Models/HitColor.metal"

#include "./Enums/ShaderModels.metal"



class Modelinator {

private:
    ShaderModels shaderModel;
    
public:
    Modelinator(ShaderModels shaderModel) {
        this->shaderModel = shaderModel;
    }
    
    float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
        switch(shaderModel) {
            case BDRF_Model:
                    return BDRF().color(ray, hit, lightPos, normal, scene);
            case SimpleShading_Model:
                return SimpleShading().color(ray, hit, lightPos, normal, scene);
            case Hit_Model:
                return Hit().color(ray, hit, lightPos, normal, scene);
            case HitColor_Model:
                return HitColor().color(ray, hit, lightPos, normal, scene);
        }
    }
    
};
