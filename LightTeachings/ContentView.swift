import SwiftUI

struct ContentView: View {
    
    // State opporators for visibilities
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var editorVisible: Bool = true
    
    @State var sceneNodeSelection: SceneBuilder.SceneNode? = nil
    
    var sceneBuilder: SceneBuilder
    @State var sceneWrapper: SceneBuilder.SceneWrapper
    
    let rendererView = RendererView()
    
    init() {
        self.sceneBuilder = SceneBuilder("lifeScene")
        self.sceneWrapper = self.sceneBuilder.getScene()
    }
    
    // Main view shown / top view
    var body: some View {

        // Navigation split view used to split the screen into two parts
        NavigationSplitView {
            SceneTree(sceneWrapper: $sceneWrapper, sceneNodeSelection: $sceneNodeSelection)
                
        } detail: {
            
            // Used to have deviders to move view size
            HSplitView {
                
                rendererView
                    .aspectRatio(1, contentMode: .fill)
                
                // Custom made inspector for the editor, splitting the screen into 3 parts
                Editor(editorVisible: $editorVisible, sceneNodeSelection: $sceneNodeSelection, sceneWrapper: $sceneWrapper)
                
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
        .onChange(of: sceneWrapper) { oldValue, newValue in
            rendererView.updateSceneWrapper(newValue)
        }
        
    }
}
