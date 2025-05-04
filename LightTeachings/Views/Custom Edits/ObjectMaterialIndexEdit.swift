import SwiftUI

struct ObjectMaterialIndexEdit: View {
    
    @Binding var index: Float
    
    var body: some View {
        Section {
            
            HStack {
                Text("Material Index")
                TextField("", value: $index, formatter: NumberFormatter())
                    .frame(width: 30)
                Stepper(value: $index, step: 1) {
                    EmptyView()
                }
            }
        }
    }
}
