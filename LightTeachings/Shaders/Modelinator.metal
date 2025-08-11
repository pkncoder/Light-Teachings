#include <metal_stdlib>

#include "./Models/BDRF.metal"
#include "./Models/SimpleShading.metal"
#include "./Models/Hit.metal"
#include "./Models/HitColor.metal"
#include "./Models/Phong.metal"

#include "./Enums/ShaderModels.metal"


// Used to figure out what shader model to use
class Modelinator {

private:
    
    // The final shader model
    ShaderModels shaderModel;
    
public:
    
    // If the model is using shadows or not
    bool shadows;
    
    // Constructor
    Modelinator(ShaderModels shaderModel) {
        
        // Set the shader model
        this->shaderModel = shaderModel;
        
        // Default shadow values
        switch(shaderModel) {
            case BRDF_Model:
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
    
    // Coloring function
    float3 color(Ray ray, HitInfoTrace hit, float3 lightPos, float3 normal, RayTracedScene scene) {
        
        // Link to the needed shader model's coloring function
        switch(shaderModel) {
            case BRDF_Model:
                return BRDF().color(ray, hit, lightPos, normal, scene);
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
    
    // Set the shadowing boolean as an override
    void setShadowOverride(bool newShadowValue) {
        this->shadows = newShadowValue;
    }
    
};
