//
//  SimpleRayTracerApp.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/9/25.
//

import SwiftUI

@main
struct SimpleRayTracerApp: App {
    
    @StateObject var rendererSettings: RendererSettings
    
    init() {
        
        let filename: String = "lifeScene.json 09-51-43-364"
        let sceneBuilder: SceneBuilder = SceneBuilder(Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "scenes")!)
        let sceneWrapper = sceneBuilder.getScene()
        
        let newAppState = RendererSettings(sceneWrapper: sceneWrapper)
        newAppState.filename = filename
        
        self._rendererSettings = StateObject(wrappedValue: newAppState)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(rendererSettings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                OpenFile()
                    .environmentObject(rendererSettings)
            }
            
            CommandGroup(replacing: .saveItem) {
                SaveFile()
                    .environmentObject(rendererSettings)
            }
        }
    }
}
