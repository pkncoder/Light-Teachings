// Wrapper for the metal object struct
struct ObjectWrapper: Hashable, Identifiable, Decodable, Encodable, Equatable {
    
    // Id
    public var id: Self { self }
    
    // Attrs
    public var origin: SIMD4<Float>
    public var bounds: SIMD4<Float>
    public var objectData: SIMD4<Float>
    public var tempData: SIMD4<Float>
    
    // Initializer
    init(origin: SIMD4<Float>, bounds: SIMD4<Float>, objectData: SIMD4<Float>, tempData: SIMD4<Float>) {
        self.origin = origin
        self.bounds = bounds
        self.objectData = objectData
        self.tempData = tempData
    }
    
    // Coding keys for JSON en/decryption
    private enum CodingKeys: CodingKey {
        case origin
        case bounds
        case objectData
        case tempData
    }
    
    // To-String method
    public var description: String {
        return
            """
            Origin: \(origin.description)
            Bounds: \(bounds.description)
            Object Data: \(objectData.description)
            Temp Data: \(tempData.description)
            """
    }
}
