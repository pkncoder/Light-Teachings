import SwiftUI

struct CylinderEditor: View {
    
    // Object binding
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed sdf opperation
            OpperationEdit(opperation: $object.objectData[1])
            
        }
        
        Section("Position and Scale") {
            
            // Cylinder Origin
            TripleItemEdit(name: "Origin", value: $object.origin)
            
            // Height
            SingleItemEdit(name: "Height", value: $object.bounds[1])
            
            // Radius
            SingleItemEdit(name: "Radius", value: $object.bounds[3])
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
        }
    }
}
