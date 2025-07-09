import SwiftUI

struct SphereEditor: View {
    
    // Object binding
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed sdf opperation
            OpperationEdit(opperation: $object.objectData[1])
            
        }
        
        Section("Position and Scale") {
            
            // Sphere Origin
            TripleItemEdit(name: "Origin", value: $object.origin)
            
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
