import SwiftUI

struct BoxEditor: View {
    
    @Binding public var object: ObjectWrapper
    
    var body: some View {
        
        Section("Object Description Settings") {
            ObjectTypeEdit(objectType: $object.objectData[0])
        }
        
        Section("Object Proporties and Interations") {
            
            // Performed sdf opperation
            OpperationEdit(opperation: $object.objectData[1])
            
            // Box Type
            BoxTypeEdit(boxType: $object.objectData[0])
            
        }
      
        Section("Position and Scale") {
            
            // Origin
            TripleItemEdit(name: "Origin", inputOneName: "X", inputTwoName: "Y", inputThreeName: "Z", value: $object.origin)
            
            // Bounds
            TripleItemEdit(name: "Scale", value: $object.bounds)
            
            // Other possible settings based on box type
            switch Objects.getObjectFromIndex(object.objectData[0]) {
                case .borderedBox:
                SingleItemEdit(name: "Border Width", value: $object.bounds[3], slidingSensitivity: 100, range: 0...10000) // Bordered box border width
                case .roundedBox:
                SingleItemEdit(name: "Rounding Amount", value: $object.bounds[3], slidingSensitivity: 100, range: 0...10000) // Rounding amount on rounded boxes
                default:
                    EmptyView()
            }
            
        }
            
        Section("Material Settings") {
            // TODO: -Make a material editor here-
            // Material Index
            ObjectMaterialIndexEdit(index: $object.objectData[3])
        }
    }
}
