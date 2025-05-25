import SwiftUI

struct CylinderEditor: View {
    
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed opperation
            OpperationEdit(opperation: $object.objectData[1])
                .onChange(of: object.objectData[1]) { old, new in
//                    print("CYL Opperation: \(new)")
                }
            
        }
        
        Section("Position and Scale") {
            
            // Cylinder Origin
            TripleItemEdit(name: "Origin", value: $object.origin)
                .onChange(of: object.origin) { old, new in
//                    print("CYL Origin: \(new)")
                }
            
            // Height
            SingleItemEdit(name: "Height", value: $object.bounds[1])
                .onChange(of: object.bounds[1]) { old, new in
//                    print("CYL Height: \(new)")
                }
            
            // Radius
            SingleItemEdit(name: "Radius", value: $object.bounds[3])
                .onChange(of: object.bounds[3]) { old, new in
//                    print("CYL Radius: \(new)")
                }
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
                .onChange(of: object.objectData[3]) { old, new in
//                    print("CYL Material Index: \(new)")
                }
            
        }
    }
}
