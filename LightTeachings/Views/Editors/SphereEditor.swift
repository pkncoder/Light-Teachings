import SwiftUI

struct SphereEditor: View {
    
    @EnvironmentObject var appState: AppState
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed opperation
            OpperationEdit(opperation: $object.objectData[1])
                .onChange(of: object.objectData[1]) { old, new in
                    print("SPH Opperation: \(new)")
                }
            
        }
        
        Section("Position and Scale") {
            
            // Sphere Origin
            TripleItemEdit(name: "Origin", value: $object.origin)
                .onChange(of: object.origin) { old, new in
                    print("SPH Origin: \(new)")
                }
            
            // Radius
            SingleItemEdit(name: "Radius", value: $object.bounds[3])
                .onChange(of: object.bounds[3]) { old, new in
                    print("SPH Radius: \(new)")
                }
            
        }
        
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
                .onChange(of: object.objectData[3]) { old, new in
                    print("SPH Material Index: \(new)")
                }
            
        }
    }
}
