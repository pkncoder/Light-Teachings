import SwiftUI

struct PlaneEditor: View {
    
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed opperation
            OpperationEdit(opperation: $object.objectData[1])
                .onChange(of: object.objectData[1]) { old, new in
//                    print("PLN Opperation: \(new)")
                }
            
        }
        
        Section("Position and Scale") {
            
            // Plane center
            TripleItemEdit(name: "Center", value: $object.origin)
                .onChange(of: object.origin) { old, new in
//                    print("PLN Origin: \(new)")
                }
                    
            // Height
            SingleItemEdit(name: "Height", value: $object.origin[3])
                .onChange(of: object.bounds[3]) { old, new in
//                    print("PLN Height: \(new)")
                }
            
            // Plane Normal
            TripleItemEdit(name: "Front Direction", value: $object.bounds)
                .onChange(of: object.bounds) { old, new in
//                    print("PLN Normal: \(new)")
                }
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
                .onChange(of: object.objectData[3]) { old, new in
//                    print("PLN Material Index: \(new)")
                }
            
        }
    }
}
