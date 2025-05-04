import SwiftUI

struct BoxEditor: View {
    
    @Binding var object: SceneBuilder.ObjectWrapper
    
    var body: some View {
        
        Section("Object Proporties and Interations") {
            
            // Performed opperation
            OpperationEdit(opperation: $object.objectData[1])
                .onChange(of: object.objectData[1]) { old, new in
                    print("BOX Opperation: \(new)")
                }
            
            // Box Type
            BoxTypeEdit(boxType: $object.objectData[0])
                .onChange(of: object.objectData[0]) { old, new in
                    print("BOX Type: \(new)")
                }
            
        }
      
        Section("Position and Scale") {
            
            // Origin
            TripleItemEdit(name: "Origin", inputOneName: "X", inputTwoName: "Y", inputThreeName: "Z", coordinate: $object.origin)
                .onChange(of: object.origin) { old, new in
                    print("BOX Origin: \(new)")
                }
            
            // Bounds
            TripleItemEdit(name: "Scale", coordinate: $object.bounds)
                .onChange(of: object.bounds) { old, new in
                    print("BOX Scale: \(new)")
                }
            
            switch Objects.getObjectFromIndex(object.objectData[0]) {
                case .borderedBox:
                    SingleItemEdit(name: "Border Width", value: $object.bounds[3])
                case .roundedBox:
                    SingleItemEdit(name: "Rounding Amount", value: $object.bounds[3])
                default:
                    EmptyView()
            }
            
        }
            
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
                .onChange(of: object.objectData[3]) { old, new in
                    print("BOX Material Index: \(new)")
                }
            
        }
    }
}
