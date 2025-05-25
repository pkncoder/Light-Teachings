import SwiftUI

struct ObjectMaterialIndexEdit: View {
    
    @Binding var index: Float
    
    var body: some View {
        Section {
            
            HStack {
                Text("Material Index")
                NumberEdit(value: $index, step: 1, slidingSensitivity: 1, intSliding: true)
            }
        }
    }
}
