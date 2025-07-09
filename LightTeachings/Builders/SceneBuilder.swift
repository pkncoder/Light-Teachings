import SwiftUI

// Scene builder class
class SceneBuilder {
    
    // URL To the file
    var sceneUrl: URL
    
    // Wrapper for the metal object struct
    struct ObjectWrapper: Hashable, Identifiable, Decodable, Encodable, Equatable {
        
        // Id
        var id: Self { self }
        
        // Attrs
        var origin: SIMD4<Float>
        var bounds: SIMD4<Float>
        var objectData: SIMD4<Float>
        var tempData: SIMD4<Float>
        
        // Initializer
        init(origin: SIMD4<Float>, bounds: SIMD4<Float>, objectData: SIMD4<Float>, tempData: SIMD4<Float>) {
            self.origin = origin
            self.bounds = bounds
            self.objectData = objectData
            self.tempData = tempData
        }
        
        // Coding keys for JSON en/decryption
        enum CodingKeys: CodingKey {
            case origin
            case bounds
            case objectData
            case tempData
        }
        
        // To-String method
        var description: String {
            return
                """
                Origin: \(origin.description)
                Bounds: \(bounds.description)
                Object Data: \(objectData.description)
                Temp Data: \(tempData.description)
                """
        }
    }
    
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
    
    // Scene node for the scene tree
    struct SceneNode: Hashable, Identifiable {
        
        // Id
        var id: Self { self }
        
        // Name
        var name: String
        
        // Data in the node
        var selectionData: SceneSelectionData?
        
        // Children
        var children: [SceneNode]? = nil
        
        // Initializer
        init(name: String, sceneSelectionType: SceneSelectionType? = nil, index: Int? = nil, children: [SceneNode]? = nil) {
            self.name = name
            self.selectionData = SceneSelectionData(selectedIndex: index, selectionType: sceneSelectionType)
            self.children = children
        }
    }
    
    // Initializer
    init(_ sceneUrl: URL) {
        self.sceneUrl = sceneUrl
    }
    
    // Returns a scene wrapper
    func getScene() -> SceneWrapper {
        
        do {
            
            // If the file exists for the sceneUrl
            if !FileManager().fileExists(atPath: sceneUrl.path) {
                fatalError("File doesn't exist")
            }
            
            // Get the json data
            let jsonData = try Data(contentsOf: sceneUrl)
            
            // Decode the json data into the scene wrapper
            let sceneWrapper = try JSONDecoder().decode(SceneWrapper.self, from: jsonData)

            // Return the final scene wrapper
            return sceneWrapper
        } catch {
            
            // If there is an error, then print it out and continue
            print(error)
        }
        
        // Send off a fatal error
        fatalError("Failed to build the Scene Wrapper.")
    }
    
    // Returns the scene node tree for the SceneTree view
    static func getNodeTree(sceneWrapper: SceneWrapper) -> SceneNode {
        
        /*
         'Title' nodes, used as headers to define what they contain. Could contain structs for settings
         */
        
        // Top level / Tree root
        var topLevelNode: SceneNode = SceneNode(name: "Scene", children: [])
        
        // Object title
        var objectNode: SceneNode = SceneNode(name: "Objects (\( Int(sceneWrapper.lengths[0])))", children: [])
        
        // Material title
        var materialNode: SceneNode = SceneNode(name: "Materials (\( Int(sceneWrapper.lengths[1])))", children: [])
        
        
        
        /* MARK: -Filling in data- */
        
        // Object data
        for i in 0...sceneWrapper.objects.count - 1 {
            
            // Create a new node && append it
            let object = sceneWrapper.objects[i]
            let newNode: SceneNode = SceneNode(name: "\(Objects.getObjectFromIndex(object.objectData[0]).rawValue)", sceneSelectionType: .Object, index: i)
            objectNode.children?.append(newNode)
        }
        
        // Material data
        for i in 0...sceneWrapper.materials.count - 1 {
            
            // Create a new node && append it
            let newNode: SceneNode = SceneNode(name: "Material \(i+1)", sceneSelectionType: .Material, index: i)
            materialNode.children?.append(newNode)
        }
        
        // Add the final nodes to the top level node
        topLevelNode.children?.append(objectNode)
        topLevelNode.children?.append(materialNode)
        
        // Return the top level / root node
        return topLevelNode
    }
}
