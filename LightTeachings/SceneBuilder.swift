import SwiftUI

// Scene builder class
class SceneBuilder {
    
    // Variable for the file name of the scene, not including extentions
    var sceneFile: String
    
    // Wrapper for the metal object struct
    struct ObjectWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        let origin: SIMD4<Float>
        let bounds: SIMD4<Float>
        let objectData: SIMD4<Float>
        let tempData: SIMD4<Float>
        
        enum CodingKeys: CodingKey {
            case origin
            case bounds
            case objectData
            case tempData
        }
    }
    
    // Wrapper for the metal material struct
    struct MaterialWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        let color: SIMD4<Float>
        
        enum CodingKeys: CodingKey {
            case color
        }
    }
    
    // Wrapper for the metal scene struct
    struct SceneWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        let objects: [ObjectWrapper]
        let materials: [MaterialWrapper]
        let lengths: SIMD4<Float>
        
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
        var heldObject: AnyHashable? = nil
        
        var children: [SceneNode]? = nil
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
    
    // Returns the type / name of an object wrapper
    func getObjectType(object: ObjectWrapper) -> String {
        
        // Switch over every object
        switch object.objectData[0] {
            case 1:
                return "Sphere"
            case 2:
                return "Box"
            case 3:
                return "Rounded Box"
            case 4:
                return "Bordered Box"
            case 5:
                return "Plane"
            case 6:
                return "Cylinder"
            default:
                return "Sphere"
        }
    }
    
    // Returns the scene node tree for the SceneTree view
    func getNodeTree(sceneWrapper: SceneWrapper) -> SceneNode {
        
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
        for object in sceneWrapper.objects {
            
            // Create a new node && append it
            let newNode: SceneNode = SceneNode(name: "\(getObjectType(object: object))", heldObject: object)
            objectNode.children?.append(newNode)
        }
        
        // Material data
        for i in 0...sceneWrapper.materials.count - 1 {
            
            // Create a new node && append it
            let newNode: SceneNode = SceneNode(name: "Material \(i+1)", heldObject: sceneWrapper.materials[i])
            materialNode.children?.append(newNode)
        }
        
        // Add the final nodes to the top level node
        topLevelNode.children?.append(objectNode)
        topLevelNode.children?.append(materialNode)
        
        // Return the top level / root node
        return topLevelNode
    }
}
