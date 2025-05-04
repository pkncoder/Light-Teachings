import SwiftUI

// Scene builder class
class SceneBuilder {
    
    // Variable for the file name of the scene, not including extentions
    var sceneFile: String
    
    // Wrapper for the metal object struct
    struct ObjectWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        var origin: SIMD4<Float>
        var bounds: SIMD4<Float>
        var objectData: SIMD4<Float>
        var tempData: SIMD4<Float>
        
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
    struct MaterialWrapper: Hashable, Identifiable, Decodable {
        
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
    struct SceneWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        var objects: [ObjectWrapper]
        var materials: [MaterialWrapper]
        var lengths: SIMD4<Float>
        
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
        var heldObjectIndex: Int? = nil
        
        var children: [SceneNode]? = nil
        
        init(name: String, heldObjectIndex: Int? = nil, children: [SceneNode]? = nil) {
            self.name = name
            self.heldObjectIndex = heldObjectIndex
            self.children = children
        }
    }
    
    // Initializer
    init(_ sceneFile: String) {
        self.sceneFile = sceneFile
    }
    
    // Returns a scene wrapper
    func getScene() -> SceneWrapper {
        
        do {
        
            // Get the file path (while catching erros) && get the json data from the bundle path
            if let bundlePath = Bundle.main.path(forResource: self.sceneFile, ofType: "json", inDirectory: "scenes"),
                let jsonData = try String(contentsOfFile: bundlePath, encoding: .utf8).data(using: .utf8) {
                     
                // Decode the json data into the scene wrapper
                let sceneWrapper = try JSONDecoder().decode(SceneWrapper.self, from: jsonData)

                // Return the final scene wrapper
                return sceneWrapper
           }
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
            let newNode: SceneNode = SceneNode(name: "\(Objects.getObjectFromIndex(object.objectData[0]).rawValue)", heldObjectIndex: i)
            objectNode.children?.append(newNode)
        }
        
        // Material data
        for i in 0...sceneWrapper.materials.count - 1 {
            
            // Create a new node && append it
            let newNode: SceneNode = SceneNode(name: "Material \(i+1)", heldObjectIndex: i + sceneWrapper.objects.count)
            materialNode.children?.append(newNode)
        }
        
        // Add the final nodes to the top level node
        topLevelNode.children?.append(objectNode)
        topLevelNode.children?.append(materialNode)
        
        // Return the top level / root node
        return topLevelNode
    }
}
