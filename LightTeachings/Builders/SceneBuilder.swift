import SwiftUI

// Scene builder class
class SceneBuilder {
    
    // URL To the file
    private var sceneUrl: URL

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
        var topLevelNode: SceneNode = SceneNode(name: "Scene", sceneSelectionType: .Scene, children: [])
        
        // Object title
        var objectNode: SceneNode = SceneNode(name: "Objects (\( Int(sceneWrapper.rendererData.arrayLengths[0])))", children: [])
        
        // Material title
        var materialNode: SceneNode = SceneNode(name: "Materials (\( Int(sceneWrapper.rendererData.arrayLengths[1])))", children: [])
        
        // Light title
        var lightNode: SceneNode = SceneNode(name: "Lights (\( Int(sceneWrapper.rendererData.arrayLengths[2])))", children: [])
        
        
        
        /* MARK: -Filling in data- */
        
        // Object data
        for i in 0...sceneWrapper.objects.count - 1 {
            
            // Create a new node && append it
            let object = sceneWrapper.objects[i]
            let newNode: SceneNode = SceneNode(name: "\(Objects.getObjectFromIndex(object.objectData[0]).rawValue) \(i+1)", sceneSelectionType: .Object, index: i)
            objectNode.children?.append(newNode)
        }
        
        // Material data
        for i in 0...sceneWrapper.materials.count - 1 {
            
            // Create a new node && append it
            let newNode: SceneNode = SceneNode(name: "Material \(i+1)", sceneSelectionType: .Material, index: i)
            materialNode.children?.append(newNode)
        }
        
        // Light data
        let newNode: SceneNode = SceneNode(name: "Light 1", sceneSelectionType: .Light, index: 0)
        lightNode.children?.append(newNode)
        
        // Add the final nodes to the top level node
        topLevelNode.children?.append(objectNode)
        topLevelNode.children?.append(materialNode)
        topLevelNode.children?.append(lightNode)
        
        // Return the top level / root node
        return topLevelNode
    }
}
