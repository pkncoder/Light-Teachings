import SwiftUI

// Wrapper for the metal material struct
struct MaterialWrapper: Hashable, Identifiable, Decodable, Encodable {
    
    // Id
    var id: Self { self }
    
    // Atttr
    var albedo: SIMD4<Float>
    var materialSettings: SIMD4<Float>
    
    // Coding keys for en/decryption
    enum CodingKeys: CodingKey {
        case albedo
        case materialSettings
    }
    
    // To-String method
    var description: String {
        return
            """
            Color: \(albedo.description)
            Roughness: \(materialSettings[0].description)
            Metalic: \(materialSettings[1].description)
            """
    }
}
