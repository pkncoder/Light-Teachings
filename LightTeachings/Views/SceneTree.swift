import SwiftUI

// View that shows all items in the scene, used to select items
struct SceneTree: View {
    
    // Scene wrapper and nodes
    @Binding var sceneWrapper: SceneBuilder.SceneWrapper
    let sceneNodes: SceneBuilder.SceneNode
    
    // Hold a state for the node selection
    @Binding var sceneNodeSelection: SceneBuilder.SceneNode?
    
    // Initializer
    init(sceneWrapper: Binding<SceneBuilder.SceneWrapper>, sceneNodeSelection: Binding<SceneBuilder.SceneNode?>) {
        
        // Get the scene wrapper and nodes
        self._sceneWrapper = sceneWrapper
        self.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: sceneWrapper.wrappedValue)
        
        // Set the node selection
        self._sceneNodeSelection = sceneNodeSelection
    }
    
    // Top level body of the SceneTree view
    var body: some View {
        VStack {
            
            // Have a list containing the outline view to stop strange sizing occourances and to make the stlye better
            List(selection: $sceneNodeSelection) { // Hold a selection variable for the outline group
                
                // Outline group holds the children of the scene ndoes and displays their names
                OutlineGroup(sceneNodes, children: \.children) { node in
                    
                    // HStack with a spacer to left-align text
                    HStack {
                        Text("\(node.name)")
                        Spacer()
                    }
                }
                
                // Top-align the outline group
                Spacer()
            }
            .listStyle(SidebarListStyle())
        }
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
    }
}
