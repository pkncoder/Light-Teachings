import SwiftUI

// Wrapper for the metal material struct
struct MaterialWrapper: Hashable, Identifiable, Decodable, Encodable {
    
    // Id
    public var id: Self { self }
    
    // Atttr
    public var albedo: SIMD4<Float>
    public var materialSettings: SIMD4<Float>
    public var temp1: SIMD4<Float>
    public var temp2: SIMD4<Float>
    
    // Coding keys for en/decryption
    private enum CodingKeys: CodingKey {
        case albedo
        case materialSettings
        case temp1
        case temp2
    }
    
    // To-String method
    public var description: String {
        return
            """
            Color: \(albedo.description)
            Roughness: \(materialSettings[0].description)
            Metalic: \(materialSettings[1].description)
            """
    }
}
