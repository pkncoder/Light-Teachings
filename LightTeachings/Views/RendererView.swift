import SwiftUI
import MetalKit

struct RendererView: NSViewRepresentable {
    
    // Renderer
    private var renderer: Renderer
    
    // For the init, just needs the rendererSettins to get the renderer
    init(rendererSettings: RendererSettings) {
        renderer = Renderer(rendererSettings: rendererSettings)
    }
    
    // Create the view for the renderer
    public func makeNSView(context: NSViewRepresentableContext<RendererView>) -> MetalViewLayer {
        
        // Get the layer
        let view = MetalViewLayer()
        view.wantsLayer = true

        // Attatch the layer to the renderer
        renderer.attachToLayer(view.metalLayer)
        
        // Return the metalViewLayer (nsView
        return view
    }
    
    // Update the Renderer View, currently unused
    public func updateNSView(_ nsView: MetalViewLayer, context: NSViewRepresentableContext<RendererView>) {}
    
    // Function to rebuild the scene buffer
    public func rebuildSceneBuffer(_ sceneWrapper: SceneWrapper) {
        renderer.rebuildSceneBuffer(sceneWrapper)
    }
    
    // Function to update the scene buffer
    public func updateSceneBuffer(sceneWrapper: SceneWrapper, updateData: UpdateData) {
        renderer.updateSceneBuffer(sceneWrapper: sceneWrapper, updateData: updateData)
    }
}
