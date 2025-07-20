import SwiftUI

struct ContentView: View {
    
    // Render settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // States for closable items
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var editorVisible: Bool = true
    
    // Scene node selection in the scene tree
    @State private var sceneNodeSelection: SceneNode? = nil
    
    // Renderer view
    @State private var rendererView: RendererView? = nil
    
    // Main view shown / top view
    var body: some View {

        // Navigation split view used to split the screen into two parts (later into 3
        NavigationSplitView {
            SceneTree(sceneNodeSelection: $sceneNodeSelection) // Scene tree to the very left for scene navigation
                
        } detail: {
            
            // Split the screen into 2 parts, one for the renderer and one for an inspector view
            HSplitView {
                
                // Make sure the renderer view has been initialized
                if let rendererUnwrappedView = rendererView {
                    rendererUnwrappedView
                    .aspectRatio(1, contentMode: .fill)
                } else {
                    Text("Loading Renderer View...")
                }
                
                // Custom made inspector for the editor, splitting the screen into 3 parts
                Editor(editorVisible: $editorVisible, sceneNodeSelection: $sceneNodeSelection)
                
            }
            .toolbar {
                // Toggle Editor view
                ToolbarItem {
                    Button {
                        editorVisible.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
            }
        }
        .font(.title)
        .onChange(of: self.rendererSettings.sceneWrapper.objects) { oldValue, newValue in
            
            // Object update, do it in a background thread
            DispatchQueue.global(qos: .background).async {
                
                self.rendererSettings.sceneWrapper.rendererData.arrayLengths[3] = rendererSettings.doIt ? 1 : 0
                
                if self.rendererSettings.updateData?.updateType == .Full {
                    rendererView!.rebuildSceneBuffer(self.rendererSettings.sceneWrapper)
                }
                
                else if let _ = rendererSettings.updateData {
                    rendererView!.updateSceneBuffer(sceneWrapper: self.rendererSettings.sceneWrapper, updateData: self.rendererSettings.updateData!)
                }
            }
        }
        .onChange(of: self.rendererSettings.sceneWrapper.materials) { oldValue, newValue in
            
            // Material update, do it in a background thread
            DispatchQueue.global(qos: .background).async {
                
                if self.rendererSettings.updateData?.updateType == .Full {
                    rendererView!.rebuildSceneBuffer(self.rendererSettings.sceneWrapper)
                    rendererSettings.updateData = nil
                }
                
                else if let _ = rendererSettings.updateData {
                    rendererView!.updateSceneBuffer(sceneWrapper: self.rendererSettings.sceneWrapper, updateData: self.rendererSettings.updateData!)
                }
            }
        }
        .onChange(of: self.rendererSettings.sceneWrapper.rendererData) { oldValue, newValue in
            
            // Material update, do it in a background thread
            DispatchQueue.global(qos: .background).async {
                
                if self.rendererSettings.updateData?.updateType == .Full {
                    rendererView!.rebuildSceneBuffer(self.rendererSettings.sceneWrapper)
                    rendererSettings.updateData = nil
                }
                
                else if let _ = rendererSettings.updateData {
                    rendererView!.updateSceneBuffer(sceneWrapper: self.rendererSettings.sceneWrapper, updateData: self.rendererSettings.updateData!)
                }
            }
        }
        .onAppear() { // Renderer settings need a sec before they can be used, so the rendererView needs to be created inside of the body
            rendererView = RendererView(rendererSettings: rendererSettings)
        }
    }
}
