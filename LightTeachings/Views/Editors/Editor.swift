import SwiftUI

// View that is used to edit things within the scene, used in conjunction with the SceneTree
struct Editor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Hold the binding with the editor visible from whatever that initializes this
    @Binding private var editorVisible: Bool
    
    // Scene node selection
    @Binding private var sceneNodeSelection: SceneNode?
    
    // Init, needs the visibility of the editor and the scene node selection
    init(editorVisible: Binding<Bool>, sceneNodeSelection: Binding<SceneNode?>) {
        self._editorVisible = editorVisible
        self._sceneNodeSelection = sceneNodeSelection
    }
    
    // Top level view for the Editor view
    var body: some View {
        
        // If the editor is visible
        if self.editorVisible {
            
            VStack {
                
                // Vstack for the other editors
                VStack {
                    
                    // Check if there actually is a selected node
                    if sceneNodeSelection != nil {
                        
                        // If the selection type is an object
                        if sceneNodeSelection?.selectionData?.selectionType == .Object && sceneNodeSelection?.selectionData?.selectedIndex ?? -1 < Int(rendererSettings.sceneWrapper.rendererData.arrayLengths[0]) {
                            
                            ObjectEditor(object: $rendererSettings.sceneWrapper.objects[sceneNodeSelection!.selectionData!.selectedIndex!], objectIndex: sceneNodeSelection!.selectionData!.selectedIndex!)
                        }
                        
                        // If the selection type is a material
                        else if sceneNodeSelection?.selectionData?.selectionType == .Material && sceneNodeSelection?.selectionData?.selectedIndex ?? -1 < Int(rendererSettings.sceneWrapper.rendererData.arrayLengths[1]) {
                            MaterialEditor(material: $rendererSettings.sceneWrapper.materials[sceneNodeSelection!.selectionData!.selectedIndex!], materialIndex: sceneNodeSelection!.selectionData!.selectedIndex!)
                        }
                        
                        // If the selected type is a title
                        else {
                            Text("You've selected a title.")
                        }
                    }
                    
                    // If nothing is selected, don't leave the view empty
                    else {
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
