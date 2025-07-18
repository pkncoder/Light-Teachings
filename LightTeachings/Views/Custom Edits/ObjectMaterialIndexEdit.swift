import SwiftUI

struct ObjectMaterialIndexEdit: View {
    
    // Index binding
    @Binding var index: Float
    
    var body: some View {
        Section {
            
            HStack {
                // Number edit for the material inedx
                Text("Material Index")
                NumberEdit(value: $index, step: 1, slidingSensitivity: 15, intSliding: true, range: 1...10)
            }
        }
    }
}
