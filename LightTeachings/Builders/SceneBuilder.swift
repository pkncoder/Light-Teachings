import SwiftUI

// Scene builder class
class SceneBuilder {
    
    // Variable for the file name of the scene, not including extentions
    var sceneUrl: URL
    
    // Wrapper for the metal object struct
    struct ObjectWrapper: Hashable, Identifiable, Decodable, Encodable, Equatable {
        
        var id: Self { self }
        
        var origin: SIMD4<Float>
        var bounds: SIMD4<Float>
        var objectData: SIMD4<Float>
        var tempData: SIMD4<Float>
        
        init(origin: SIMD4<Float>, bounds: SIMD4<Float>, objectData: SIMD4<Float>, tempData: SIMD4<Float>) {
            self.origin = origin
            self.bounds = bounds
            self.objectData = objectData
            self.tempData = tempData
        }
        
        enum CodingKeys: CodingKey {
            case origin
            case bounds
            case objectData
            case tempData
        }
        
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
        
        var id: Self { self }
        
        var albedo: SIMD4<Float>
        var materialSettings: SIMD4<Float>
        
        
        enum CodingKeys: CodingKey {
            case albedo
            case materialSettings
        }
        
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
        static func == (lhs: SceneWrapper, rhs: SceneWrapper) -> Bool {
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
        
        
        var id: Self { self }
        
        var objects: [ObjectWrapper]
        var materials: [MaterialWrapper]
        var lengths: SIMD4<Float>
        
        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.objects = try container.decode([ObjectWrapper].self, forKey: .objects)
            self.materials = try container.decode([MaterialWrapper].self, forKey: .materials)
            self.lengths = try container.decode(SIMD4<Float>.self, forKey: .lengths)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(objects, forKey: .objects)
            try container.encode(materials, forKey: .materials)
            try container.encode(lengths, forKey: .lengths)
        }
        
        enum CodingKeys: CodingKey {
            case objects
            case materials
            case lengths
        }
    }
    
    // Scene node for the scene tree
    struct SceneNode: Hashable, Identifiable {
        
        var id: Self { self }
        
        var name: String
        var selectionData: SceneSelectionData?
        
        var children: [SceneNode]? = nil
        
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
            
            if !FileManager().fileExists(atPath: sceneUrl.path) {
                fatalError("File doesn't exist")
            }
            
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
