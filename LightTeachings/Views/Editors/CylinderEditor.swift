import SwiftUI

struct CylinderEditor: View {
    
    // Object binding
    @Binding public var object: ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed sdf opperation
            OpperationEdit(opperation: $object.objectData[1])
            
        }
        
        Section("Position and Scale") {
            
            // Cylinder Origin
            TripleItemEdit(name: "Origin", value: $object.origin)
            
            // Cylinder Normal
            TripleItemEdit(name: "Normal", value: $object.bounds)
            
            // Height
            SingleItemEdit(name: "Height", value: $object.origin[3])
            
            // Radius
            SingleItemEdit(name: "Radius", value: $object.bounds[3], slidingSensitivity: 25, range: 0...10000)
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
        }
    }
}
