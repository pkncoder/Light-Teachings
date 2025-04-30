import SwiftUI

// View that is used to edit things within the scene, used in conjunction with the SceneTree
struct Editor: View {
    
    // Hold the binding with the editor visible from whatever that initializes this
    @Binding var editorVisible: Bool
    
    // Top level view for the Editor view
    var body: some View {
        
        // If the editor is visible
        if self.editorVisible {
            
            // Full that contains all editor stuff
            VStack {
                
                // VStack that holds all info, and that is modified with inspector-like qualities
                VStack {
                    
                }
                .ignoresSafeArea()
                .frame(maxWidth: 300)
                
                Spacer()
            }
        }
    }
}
