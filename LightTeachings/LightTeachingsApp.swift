//
//  SimpleRayTracerApp.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/9/25.
//

import SwiftUI

@main
struct SimpleRayTracerApp: App {
    
    @StateObject var appState: AppState
    
    init() {
        
        let filename: String = "lifeScene"
        let sceneBuilder: SceneBuilder = SceneBuilder(filename)
        let sceneWrapper = sceneBuilder.getScene()
        
        let newAppState = AppState(sceneWrapper: sceneWrapper)
//        newAppState.sceneWrapper = sceneWrapper
        newAppState.filename = filename
        
        self._appState = StateObject(wrappedValue: newAppState)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                OpenFile()
            }
            
            CommandGroup(replacing: .saveItem) {
                SaveFile()
            }
        }
    }
}
