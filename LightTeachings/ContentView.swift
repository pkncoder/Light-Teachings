import SwiftUI

struct ContentView: View {
    
    // State opporators for visibilities
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var editorVisible: Bool = true
    
    @State var sceneNodeSelection: SceneBuilder.SceneNode? = nil
    
    @State var rendererView: RendererView? = nil
    
    @EnvironmentObject var appState: AppState
    
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
                    Text("wait")
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
        .onChange(of: self.appState.sceneWrapper.objects) { oldValue, newValue in
            rendererView!.rebuildSceneBuffer(appState.sceneWrapper)
            print("Content View Update | \(appState.sceneWrapper.objects[0].bounds)")
        }
        .onAppear() {
            rendererView = RendererView(appState: appState)
            print("CONTENT VIEW APPEARED")
        }
    }
}
