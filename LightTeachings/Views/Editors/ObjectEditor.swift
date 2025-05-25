import SwiftUI

struct ObjectEditor: View {
    
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        // TODO: -REPEATED CODE WEEWOOWEEWOO-
        
        List {
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
        .onChange(of: self.object) { oldValue, newValue in
            print("OBJ EDITOR | CHANGE")
        }
    }
}
