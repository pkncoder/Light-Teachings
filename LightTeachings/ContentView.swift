import SwiftUI

struct ContentView: View {
    
    // State opporators for visibilities
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var editorVisible: Bool = true
    
    // Main view shown / top view
    var body: some View {

        // Navigation split view used to split the screen into two parts
        NavigationSplitView {
            SceneTree()
                
        } detail: {
            
            // Used to have deviders to move view size
            HSplitView {
                
                RendererView()
                    .aspectRatio(1, contentMode: .fill)
                
                // Custom made inspector for the editor, splitting the screen into 3 parts
                Editor(editorVisible: $editorVisible)
                
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
        
    }
}
