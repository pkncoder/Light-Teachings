import SwiftUI

// View that is used to edit things within the scene, used in conjunction with the SceneTree
struct Editor: View {
    
    // Hold the binding with the editor visible from whatever that initializes this
    @Binding var editorVisible: Bool
    @Binding var sceneNodeSelection: SceneBuilder.SceneNode?
    
    @State var value: Float = 0.0
    
    @EnvironmentObject var rendererSettings: RendererSettings
    
    init(editorVisible: Binding<Bool>, sceneNodeSelection: Binding<SceneBuilder.SceneNode?>) {
        
        self._editorVisible = editorVisible
        self._sceneNodeSelection = sceneNodeSelection
    }
    
    // Top level view for the Editor view
    var body: some View {
        
        // If the editor is visible
        if self.editorVisible {
            
            // Full that contains all editor stuff
            VStack {
                
                // VStack that holds all info, and that is modified with inspector-like qualities
                VStack {
                    if sceneNodeSelection != nil {
                        if sceneNodeSelection?.selectionData?.selectionType == .Object {
                            ObjectEditor(object: $rendererSettings.sceneWrapper.objects[sceneNodeSelection!.selectionData!.selectedIndex!])
                        } else if sceneNodeSelection?.selectionData?.selectionType == .Material {
                            MaterialEditor(material: $rendererSettings.sceneWrapper.materials[sceneNodeSelection!.selectionData!.selectedIndex!])
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
            .onChange(of: self.rendererSettings) { oldValue, newValue in
                print("EDITOR: Update")
            }
        }
    }
}
