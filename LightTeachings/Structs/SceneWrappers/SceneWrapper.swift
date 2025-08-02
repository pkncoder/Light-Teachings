import SwiftUI

// Wrapper for the metal scene struct
@Observable
class SceneWrapper: Hashable, Decodable, Encodable {
    
    // == method
    public static func == (lhs: SceneWrapper, rhs: SceneWrapper) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    // Hash
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    // Id
    public var id: Self { self }
    
    // Attrs
    public var objects: [ObjectWrapper]
    public var materials: [MaterialWrapper]
    public var light: LightWrapper
    public var rendererData: RendererDataWrapper
    
    // Decoder init
    required init(from decoder: any Decoder) throws {
        
        // Get a container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode all of the objects, materials and lengths
        self.objects = try container.decode([ObjectWrapper].self, forKey: .objects)
        self.materials = try container.decode([MaterialWrapper].self, forKey: .materials)
        self.light = try container.decode(LightWrapper.self, forKey: .light)
        self.rendererData = try container.decode(RendererDataWrapper.self, forKey: .rendererData)
    }
    
    // Encoder
    public func encode(to encoder: any Encoder) throws {
        
        // Get a container
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Try to encode all of the objects, materials and lengths
        try container.encode(objects, forKey: .objects)
        try container.encode(materials, forKey: .materials)
        try container.encode(light, forKey: .light)
        try container.encode(rendererData, forKey: .rendererData)
    }
    
    // Coding keys
    private enum CodingKeys: CodingKey {
        case objects
        case materials
        case light
        case rendererData
    }
}
