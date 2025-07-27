import SwiftUI

// Wrapper for the metal material struct
struct RendererDataWrapper: Hashable, Identifiable, Decodable, Encodable {
    
    // Id
    public var id: Self { self }
    
    // Atttr
    public var arrayLengths: SIMD4<Float>
    public var shadingData: SIMD4<Float>
    public var ambient: SIMD4<Float>
    public var temp3: SIMD4<Float>
    
    // Coding keys for en/decryption
    private enum CodingKeys: CodingKey {
        case arrayLengths
        case shadingData
        case ambient
        case temp3
    }
    
    // To-String method
    public var description: String {
        return
            """
            Lengths: \(arrayLengths.description)
            Shading Data: \(shadingData[0].description)
            Albedo: \(ambient.description)
            """
    }
}
