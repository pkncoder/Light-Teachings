import SwiftUI

// Wrapper for the metal object struct
struct LightWrapper: Hashable, Identifiable, Decodable, Encodable, Equatable {
    
    // Id
    public var id: Self { self }
    
    // Attrs
    public var origin: SIMD4<Float>
    public var albedo: SIMD4<Float>
    public var temp1: SIMD4<Float>
    public var temp2: SIMD4<Float>
    
    // Initializer
    init(origin: SIMD4<Float>, albedo: SIMD4<Float>) {
        self.origin = origin
        self.albedo = albedo
        self.temp1 = SIMD4<Float>(repeating: 0)
        self.temp2 = SIMD4<Float>(repeating: 0)
    }
    
    // Coding keys for JSON en/decryption
    private enum CodingKeys: CodingKey {
        case origin
        case albedo
        case temp1
        case temp2
    }
    
    // To-String method
    public var description: String {
        return
            """
            Origin: \(origin.description)
            Color: \(albedo.description)
            """
    }
}
