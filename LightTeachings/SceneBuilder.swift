//
//  SceneBuilder.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/24/25.
//

import Foundation

class SceneBuilder {
    var sceneFile: String
    
    struct ObjectWrapper: Decodable {
        let origin: SIMD4<Float>
        let bounds: SIMD4<Float>
        let objectData: SIMD4<Float>
        let tempData: SIMD4<Float>
    }
    
    struct MaterialWrapper: Decodable {
        let color: SIMD4<Float>
//        let emmisive: SIMD4<Float>
//        let specularColor: SIMD4<Float>
//        let materialSettings: SIMD4<Float>
    }
    
    struct SceneWrapper: Decodable {
        let objects: [ObjectWrapper]
        let materials: [MaterialWrapper]
        let lengths: SIMD4<Float>
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

                // Return the final scene wrapper-0
                return sceneWrapper
           }
        } catch {
           print(error)
        }
        
        fatalError("Failed to get the object array from json file")
    }
}
