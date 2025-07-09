import SwiftUI

struct PlaneEditor: View {
    
    // Object binding
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed sdf opperation
            OpperationEdit(opperation: $object.objectData[1])
            
        }
        
        Section("Position and Scale") {
            
            // Plane center
            TripleItemEdit(name: "Center", value: $object.origin)
                    
            // Height
            SingleItemEdit(name: "Height", value: $object.origin[3])
            
            // Plane Normal
            TripleItemEdit(name: "Front Direction", value: $object.bounds)
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
        }
    }
}
