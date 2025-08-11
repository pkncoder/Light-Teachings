import SwiftUI

struct PlaneEditor: View {
    
    // Object binding
    @Binding public var object: ObjectWrapper
    
    var body: some View {
        
        Section("Object Description Settings") {
            ObjectTypeEdit(objectType: $object.objectData[0])
        }
        
        Section("Position and Scale") {
            
            // Height
            SingleItemEdit(name: "Plane Height", value: $object.origin[3])
            
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
