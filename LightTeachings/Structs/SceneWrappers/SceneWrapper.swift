import SwiftUI

// Wrapper for the metal scene struct
@Observable
class SceneWrapper: Hashable, Decodable, Encodable {
    
    // == method
    static func == (lhs: SceneWrapper, rhs: SceneWrapper) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    // Hash
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    // Id
    var id: Self { self }
    
    // Attrs
    var objects: [ObjectWrapper]
    var materials: [MaterialWrapper]
    var lengths: SIMD4<Float>
    
    // Decoder init
    required init(from decoder: any Decoder) throws {
        
        // Get a container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode all of the objects, materials and lengths
        self.objects = try container.decode([ObjectWrapper].self, forKey: .objects)
        self.materials = try container.decode([MaterialWrapper].self, forKey: .materials)
        self.lengths = try container.decode(SIMD4<Float>.self, forKey: .lengths)
    }
    
    // Encoder
    func encode(to encoder: any Encoder) throws {
        
        // Get a container
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Try to encode all of the objects, materials and lengths
        try container.encode(objects, forKey: .objects)
        try container.encode(materials, forKey: .materials)
        try container.encode(lengths, forKey: .lengths)
    }
    
    // Coding keys
    enum CodingKeys: CodingKey {
        case objects
        case materials
        case lengths
    }
}
