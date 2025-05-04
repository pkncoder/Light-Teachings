enum Opperations: String, CaseIterable {
    case union = "Union"
    case difference = "Difference"
    case intercept = "Intercept"
    
    static func getOpperationFromIndex(_ index: Float) -> Self {
        switch index {
            case 0:
                return .union
            case 1:
                return .difference
            case 2:
                return .intercept
            default:
                return .union
        }
    }
    
    static func getIndexFromOpperation(_ opperation: Self) -> Float {
        switch opperation {
            case .union:
                return 0.0
            case .difference:
                return 1.0
            case .intercept:
                return 2.0
        }
    }
}
