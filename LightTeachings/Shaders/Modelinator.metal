#include <metal_stdlib>

#include "./Models/BDRF.metal"
#include "./Models/SimpleShading.metal"
#include "./Models/Hit.metal"
#include "./Models/HitColor.metal"
#include "./Models/Phong.metal"

#include "./Enums/ShaderModels.metal"



class Modelinator {

private:
    ShaderModels shaderModel;
    
public:
    bool shadows;
    
    Modelinator(ShaderModels shaderModel) {
        this->shaderModel = shaderModel;
        
        switch(shaderModel) {
            case BDRF_Model:
                this->shadows = true;
                break;
            case Phong_Model:
                this->shadows = true;
                break;
            case SimpleShading_Model:
                this->shadows = false;
                break;
            case Hit_Model:
                this->shadows = false;
                break;
            case HitColor_Model:
                this->shadows = false;
                break;
        }
        
    }
    
    float3 color(Ray ray, HitInfo hit, float3 lightPos, float3 normal, RayTracedScene scene) {
        
        switch(shaderModel) {
            case BDRF_Model:
                    return BDRF().color(ray, hit, lightPos, normal, scene);
            case Phong_Model:
                return Phong().color(ray, hit, lightPos, normal, scene);
            case SimpleShading_Model:
                return SimpleShading().color(ray, hit, lightPos, normal, scene);
            case Hit_Model:
                return Hit().color(ray, hit, lightPos, normal, scene);
            case HitColor_Model:
                return HitColor().color(ray, hit, lightPos, normal, scene);
        }
    }
    
    void setShadowOverride(bool newShadowValue) {
        this->shadows = newShadowValue;
    }
    
};
