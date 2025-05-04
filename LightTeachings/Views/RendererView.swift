import SwiftUI
import MetalKit

// The view controller for the renderer
struct RendererView: NSViewRepresentable {
    
    // Renderer
    @State var renderer: Renderer = Renderer()
    
    // Create the view for the renderer
    func makeNSView(context: NSViewRepresentableContext<RendererView>) -> MTKView {
        
        // Initialize the Metal View
        let mtkView = MTKView()
        mtkView.delegate = renderer // Set the delagate that controlls and makes objects for the view
        mtkView.preferredFramesPerSecond = 60 // Set perfered fps (basiclly like a fps cap)
        mtkView.enableSetNeedsDisplay = true // Set that we do indeed need a display
        
        // Create the metal device
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        // There is not only a framebuffer for the render
        mtkView.framebufferOnly = false
        
        // Set the drawable size
        mtkView.drawableSize = mtkView.frame.size
        
        // Turn off isPaused so the view continues to render as many times per second as set (soft-capped at 60)
        mtkView.isPaused = false
        
        // Return our full mtkview
        return mtkView
    }
    
    // Update the Renderer View, currently unused
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<RendererView>) {}
    
    func updateSceneWrapper(_ sceneWrapper: SceneBuilder.SceneWrapper) {
        renderer.sceneWrapper = sceneWrapper
        renderer.rebuildSceneBuffer()
    }
}
