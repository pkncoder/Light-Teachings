//
//  SimpleRayTracerApp.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/9/25.
//

import SwiftUI

@main
struct SimpleRayTracerApp: App {
    
    // Mostly global memory for updating the renderer and saving info
    @StateObject public var rendererSettings: RendererSettings
    
    // Init
    init() {
      
        // Base file for the renderer
        let filename: String = "objects"
        
        // Create a scene builder with the base file
        let sceneBuilder: SceneBuilder = SceneBuilder(Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "scenes")!)
        
        // Gain a scene wrapper
        let sceneWrapper = sceneBuilder.getScene()
        
        // Get the new render settings
        let newRenderSettings = RendererSettings(sceneWrapper: sceneWrapper)
        newRenderSettings.filename = filename
        
        // Set the newRenderSettings for the base render settings
        self._rendererSettings = StateObject(wrappedValue: newRenderSettings)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView() // Content View
                .environmentObject(rendererSettings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                OpenFile() // Open a scene
                    .environmentObject(rendererSettings)
            }
            
            CommandGroup(replacing: .saveItem) {
                SaveFile() // Save a scene
                    .environmentObject(rendererSettings)
            }
            
            YoutubeLinksCommands()
        }
    }
}
