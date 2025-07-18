import SwiftUI

struct PlaneEditor: View {
    
    // Object binding
    @Binding var object: ObjectWrapper
    
    var body: some View {
        
        Section("Object Description Settings") {
            ObjectTypeEdit(objectType: $object.objectData[0])
        }
        
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
            TripleItemEdit(name: "Front Direction", value: $object.bounds, slidingSensitivity: 75)
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
        }
    }
}
