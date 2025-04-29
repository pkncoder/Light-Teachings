//
//  SceneBuilder.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/24/25.
//

import SwiftUI

class SceneBuilder {
    var sceneFile: String
    
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
    
    struct MaterialWrapper: Hashable, Identifiable, Decodable {
        
        var id: Self { self }
        
        let color: SIMD4<Float>
        
        enum CodingKeys: CodingKey {
            case color
        }
    }
    
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
    
    struct SceneNode: Hashable, Identifiable {
        
        var id: Self { self }
        
        var name: String
        var heldObject: AnyHashable? = nil
        
        var children: [SceneNode]? = nil
    }
    
    init(_ sceneFile: String) {
        self.sceneFile = sceneFile
    }
    
    func getScene() -> SceneWrapper {
        
        do {
        
           // creating a path from the main bundle and getting data object from the path
            if let bundlePath = Bundle.main.path(forResource: self.sceneFile, ofType: "json", inDirectory: "scenes"),
              let jsonData = try String(contentsOfFile: bundlePath, encoding: .utf8).data(using: .utf8) {
                 
                // Decoding the Product type from JSON data using JSONDecoder() class.
                let sceneWrapper = try JSONDecoder().decode(SceneWrapper.self, from: jsonData)

                // Return the final scene wrapper
                return sceneWrapper
           }
        } catch {
           print(error)
        }
        
        fatalError("Failed to build the Scene Wrapper.")
    }
    
    func getNodeTree(sceneWrapper: SceneWrapper) -> SceneNode {
        
        var topLevelNode: SceneNode = SceneNode(name: "Scene", children: [])
        
        // Objects
        var objectNode: SceneNode = SceneNode(name: "Objects", children: [])
        
        for object in sceneWrapper.objects {
            
            let newNode: SceneNode = SceneNode(name: "Object", heldObject: object)
            objectNode.children?.append(newNode)
        }
        
        // Materials
        var materialNode: SceneNode = SceneNode(name: "Materials", children: [])
        
        for material in sceneWrapper.materials {
            
            let newNode: SceneNode = SceneNode(name: "Material", heldObject: material)
            materialNode.children?.append(newNode)
        }
        
        topLevelNode.children?.append(objectNode)
        topLevelNode.children?.append(materialNode)
        
        return topLevelNode
    }
}
