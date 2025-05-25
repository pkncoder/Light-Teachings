import SwiftUI

// View that shows all items in the scene, used to select items
struct SceneTree: View {
    
    @State var sceneNodes: SceneBuilder.SceneNode? = nil
    
    @EnvironmentObject var appState: AppState
    
    // Hold a state for the node selection
    @Binding var sceneNodeSelection: SceneBuilder.SceneNode?
    
    // Initializer
    init(sceneNodeSelection: Binding<SceneBuilder.SceneNode?>) {
        
//        @EnvironmentObject var appState: AppState
        
        // Get the scene wrapper and nodes
//        self.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: appState.sceneWrapper)
        
        // Set the node selection
        self._sceneNodeSelection = sceneNodeSelection
    }
    
    // Top level body of the SceneTree view
    var body: some View {
        VStack {
            
            // Have a list containing the outline view to stop strange sizing occourances and to make the stlye better
            List(selection: $sceneNodeSelection) { // Hold a selection variable for the outline group
                
                // Outline group holds the children of the scene ndoes and displays their names
                
                if let unwrappedSceneNodes = self.sceneNodes {
                    
                    OutlineGroup(unwrappedSceneNodes, children: \.children) { node in
                        
                        // HStack with a spacer to left-align text
                        HStack {
                            Text("\(node.name)")
                            Spacer()
                        }
                    }
                } else {
                    Text("Wait")
                }
                
                // Top-align the outline group
                Spacer()
            }
            .listStyle(SidebarListStyle())
        }
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        .onAppear() {
            self.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: appState.sceneWrapper)
        }
    }
}
