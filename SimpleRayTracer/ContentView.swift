//
//  ContentView.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import SwiftUI
import MetalKit

// Main content view using the ui view so updating the ui view can be loaded
struct RendererView: UIViewRepresentable {
    
    // Get a renderer
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // Create the view for mtkview
    func makeUIView(context: UIViewRepresentableContext<RendererView>) -> MTKView {
        
        // Create the view
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator.renderer // Get the delegate
        mtkView.preferredFramesPerSecond = 60 // Set perfered fps
        mtkView.enableSetNeedsDisplay = true // Set that we do indeed need a displace
        
        // Create the metal device
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        // No framebuffer only
        mtkView.framebufferOnly = false
        
        // Set the drawable size
        mtkView.drawableSize = mtkView.frame.size
        
        // Return our full mtkview
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<RendererView>) {
        
    }
}

struct ContentView: View {
    
    var body: some View {
        VStack {
            RendererView()
        }
    }
}
