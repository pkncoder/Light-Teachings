import SwiftUI
import MetalKit

class MetalViewLayer: NSView {
    override func makeBackingLayer() -> CALayer {
        let metalLayer = CAMetalLayer()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        return metalLayer
    }

    var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }
}

// The view controller for the renderer
struct RendererView: NSViewRepresentable {
    
    // Renderer
    var renderer: Renderer
    
    init(rendererSettings: RendererSettings) {
        renderer = Renderer(rendererSettings: rendererSettings)
    }
    
    // Create the view for the renderer
    func makeNSView(context: NSViewRepresentableContext<RendererView>) -> MetalViewLayer {
        
        let view = MetalViewLayer()
        view.wantsLayer = true
        renderer.attachToLayer(view.metalLayer)
        
        // Return our full mtkview
        return view
    }
    
    // Update the Renderer View, currently unused
    func updateNSView(_ nsView: MetalViewLayer, context: NSViewRepresentableContext<RendererView>) {}
    
    func rebuildSceneBuffer(_ sceneWrapper: SceneBuilder.SceneWrapper) {
        renderer.rebuildSceneBuffer(sceneWrapper)
        print("Rebuilding")
    }
    
    func updateSceneBuffer(sceneWrapper: SceneBuilder.SceneWrapper, updateData: UpdateData) {
        
        // Prepare new buffer in the background
//        DispatchQueue.global(qos: .background).async {
            renderer.updateSceneBuffer(sceneWrapper: sceneWrapper, updateData: updateData)
//        }
        
        print("Updating")
    }
}
