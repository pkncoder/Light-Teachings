import SwiftUI

struct ContentView: View {
    
    // State opporators for visibilities
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var editorVisible: Bool = true
    
    @State var sceneNodeSelection: SceneBuilder.SceneNode? = nil
    
    @State var rendererView: RendererView? = nil
    
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Main view shown / top view
    var body: some View {

        // Navigation split view used to split the screen into two parts
        NavigationSplitView {
            SceneTree(sceneNodeSelection: $sceneNodeSelection)
                
        } detail: {
            
            // Used to have deviders to move view size
            HSplitView {
                
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
            
            DispatchQueue.global(qos: .background).async {
                if let _ = rendererSettings.updateData {
                    rendererView!.updateSceneBuffer(sceneWrapper: self.rendererSettings.sceneWrapper, updateData: self.rendererSettings.updateData!)
                    print("Content View Update")
                }
            }
            
            self.rendererSettings.updateData = nil
        }
        .onAppear() {
            rendererView = RendererView(rendererSettings: rendererSettings)
        }
    }
}
