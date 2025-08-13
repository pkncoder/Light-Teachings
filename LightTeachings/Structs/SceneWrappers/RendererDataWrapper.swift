import SwiftUI

// Wrapper for the metal material struct
struct RendererDataWrapper: Hashable, Identifiable, Decodable, Encodable {
    
    // Id
    public var id: Self { self }
    
    // Atttr
    public var arrayLengths: SIMD4<Float>
    public var shadingData: SIMD4<Float>
    public var ambient: SIMD4<Float>
    public var camera1: SIMD4<Float>
    public var camera2: SIMD4<Float>
    
    // Coding keys for en/decryption
    private enum CodingKeys: CodingKey {
        case arrayLengths
        case shadingData
        case ambient
        case camera1
        case camera2
    }
    
    // To-String method
    public var description: String {
        return
            """
            Lengths: \(arrayLengths.description)
            Shading Data: \(shadingData[0].description)
            Albedo: \(ambient.description)
            Camera1: \(camera1.description)
            Camera2: \(camera2.description)
            """
    }
}
