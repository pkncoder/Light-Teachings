import SwiftUI

// View that is used to edit things within the scene, used in conjunction with the SceneTree
struct Editor: View {
    
    // Hold the binding with the editor visible from whatever that initializes this
    @Binding var editorVisible: Bool
    @Binding var sceneNodeSelection: SceneBuilder.SceneNode?
    @Binding var sceneWrapper: SceneBuilder.SceneWrapper
    
    // Top level view for the Editor view
    var body: some View {
        
        // If the editor is visible
        if self.editorVisible {
            
            // Full that contains all editor stuff
            VStack {
                
                // VStack that holds all info, and that is modified with inspector-like qualities
                VStack {
                    if sceneNodeSelection != nil {
                        if sceneNodeSelection?.heldObjectIndex ?? 255 < sceneWrapper.objects.count {
                            ObjectEditor(object: $sceneWrapper.objects[sceneNodeSelection!.heldObjectIndex!])
                        } else if sceneNodeSelection?.heldObjectIndex ?? 255 < sceneWrapper.objects.count + sceneWrapper.materials.count {
                            MaterialEditor(material: $sceneWrapper.materials[sceneNodeSelection!.heldObjectIndex! - sceneWrapper.objects.count])
                        } else {
                            Text("You've selected a Title")
                        }
                    } else {
                        Text("No item is selected at the moment!")
                    }
                }
                .frame(maxWidth: 300, maxHeight: .infinity)
                .font(.subheadline)
                
                Spacer()
            }
        }
    }
}
