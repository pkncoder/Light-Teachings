import SwiftUI

// View that shows all items in the scene, used to select items
struct SceneTree: View {
    
    // Scene builder, wrapper, and nodes
    let sceneBuilder: SceneBuilder
    let sceneWrapper: SceneBuilder.SceneWrapper
    let sceneNodes: SceneBuilder.SceneNode
    
    // Hold a state for the node selection
    @State var selection: SceneBuilder.SceneNode? = nil
    
    // Initializer
    init() {
        
        // Build the scene
        self.sceneBuilder = SceneBuilder("lifeScene")
        
        // Get the scene wrapper and nodes
        self.sceneWrapper = sceneBuilder.getScene()
        self.sceneNodes = sceneBuilder.getNodeTree(sceneWrapper: sceneWrapper)
    }
    
    // Top level body of the SceneTree view
    var body: some View {
        VStack {
            
            // Have a list containing the outline view to stop strange sizing occourances and to make the stlye better
            List(selection: $selection) { // Hold a selection variable for the outline group
                
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
        .padding()
    }
}
