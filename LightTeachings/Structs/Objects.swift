// Different objects, float conversions, and object groups
enum Objects: String, CaseIterable {
    case sphere = "Sphere"
    case box = "Box"
    case roundedBox = "Rounded Box"
    case borderedBox = "Bordered Box"
    case plane = "Plane"
    case cylinder = "Cylinder"
    
    // Float -> Object
    static func getObjectFromIndex(_ index: Float) -> Self {
        switch index {
            case 1:
                return .sphere
            case 2:
                return .box
            case 3:
                return .roundedBox
            case 4:
                return .borderedBox
            case 5:
                return .plane
            case 6:
                return .cylinder
            default:
                return .sphere
        }
    }
    
    // Object -> Float
    static func getIndexFromObject(_ object: Self) -> Float {
        switch object {
            case .sphere:
                return 1
            case .box:
                return 2
            case .roundedBox:
                return 3
            case .borderedBox:
                return 4
            case .plane:
                return 5
            case .cylinder:
                return 6
        }
    }
    
    // All box typ
    static var allBoxes: [Self] {
        return [Self.box, Self.roundedBox, Self.borderedBox]
    }
}
