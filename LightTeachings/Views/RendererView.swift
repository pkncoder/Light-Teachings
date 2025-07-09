import SwiftUI
import MetalKit

class MetalViewLayer: NSView {
    
    // Create the layer for the NSView
    override func makeBackingLayer() -> CALayer {
        let metalLayer = CAMetalLayer()
        metalLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        return metalLayer
    }

    // Saved layer (as a CAMetalLayer)
    var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }
}

struct RendererView: NSViewRepresentable {
    
    // Renderer
    var renderer: Renderer
    
    // For the init, just needs the rendererSettins to get the renderer
    init(rendererSettings: RendererSettings) {
        renderer = Renderer(rendererSettings: rendererSettings)
    }
    
    // Create the view for the renderer
    func makeNSView(context: NSViewRepresentableContext<RendererView>) -> MetalViewLayer {
        
        // Get the layer
        let view = MetalViewLayer()
        view.wantsLayer = true

        // Attatch the layer to the renderer
        renderer.attachToLayer(view.metalLayer)
        
        // Return the metalViewLayer (nsView
        return view
    }
    
    // Update the Renderer View, currently unused
    func updateNSView(_ nsView: MetalViewLayer, context: NSViewRepresentableContext<RendererView>) {}
    
    // Function to rebuild the scene buffer
    func rebuildSceneBuffer(_ sceneWrapper: SceneBuilder.SceneWrapper) {
        renderer.rebuildSceneBuffer(sceneWrapper)
    }
    
    // Function to update the scene buffer
    func updateSceneBuffer(sceneWrapper: SceneBuilder.SceneWrapper, updateData: UpdateData) {
        renderer.updateSceneBuffer(sceneWrapper: sceneWrapper, updateData: updateData)
    }
}
