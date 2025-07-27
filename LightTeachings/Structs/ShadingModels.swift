// Shading models, included with float conversions
enum ShadingModels: String, CaseIterable {
    case bdrf = "BDRF"
    case phong = "Phong"
    case simpleShading = "Simple Shading"
    case hit = "Hit Detect"
    case hitColor = "Colored Hit Detect"
    
    // Float to Model
    public static func getModelFromIndex(_ index: Float) -> Self {
        switch index {
            case 1:
                return .bdrf
            case 2:
                return .phong
            case 3:
                return .simpleShading
            case 4:
                return .hit
            case 5:
                return .hitColor
            default:
                return .bdrf
        }
    }
    
    // Model to Float
    public static func getIndexFromModel(_ model: Self) -> Float {
        switch model {
            case .bdrf:
                return 1.0
            case .phong:
                return 2.0
            case .simpleShading:
                return 3.0
            case .hit:
                return 4.0
            case .hitColor:
                return 5.0
        }
    }
    
    // Default shading data
    public static func getDefaultShading(_ model: Self) -> Float {
        switch model {
            case self.bdrf, self.simpleShading, self.phong:
                return 1.0
            case self.hit, self.hitColor:
                return 0.0
            default:
                return 0.0
        }
    }
}
