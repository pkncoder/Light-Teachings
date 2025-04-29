//
//  RendererView.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 4/29/25.
//

import SwiftUI
import MetalKit

struct RendererView: NSViewRepresentable {
    
    @State private var renderer: Renderer = Renderer()
    
    
    // Create the view for mtkview
    func makeNSView(context: NSViewRepresentableContext<RendererView>) -> MTKView {
        // Create the view
        let mtkView = MTKView()
        mtkView.delegate = renderer // Get the delegate
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
        
        mtkView.isPaused = false
        
        // Return our full mtkview
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<RendererView>) {
        
    }
}
