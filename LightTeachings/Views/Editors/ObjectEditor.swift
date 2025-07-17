import SwiftUI

struct ObjectEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Object info
    @Binding var object: SceneBuilder.ObjectWrapper
    var objectIndex: Int
    
    var body: some View {
        
        // TODO: -REPEATED CODE WEEWOOWEEWOO-
        
        // List here for style choices in the other editors
        List {
            
            // This shows what kind of object editor to use
            if (object.objectData[0] == 1) {
                
                // Sphere
                SphereEditor(object: $object)
                
            } else if (object.objectData[0] == 2) {
                
                // Box
                BoxEditor(object: $object)
                
            } else if (object.objectData[0] == 3) {
                
                // Box
                BoxEditor(object: $object)
                
            } else if (object.objectData[0] == 4) {
                
                // Box
                BoxEditor(object: $object)
                
            } else if (object.objectData[0] == 5) {
                
                // Plane
                PlaneEditor(object: $object)
                
            } else if (object.objectData[0] == 6) {
                
                // Cylinder
                CylinderEditor(object: $object)
            }
            
            else {
                Text("Object is invallid or editor is not supported yet")
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: self.rendererSettings.sceneWrapper.objects) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if self.rendererSettings.updateData?.updateType == .Full { return }
            
            rendererSettings.updateData = UpdateData(updateType: .Object, updateIndex: objectIndex)
        }
    }
}
