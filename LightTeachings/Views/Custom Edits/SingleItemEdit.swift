import SwiftUI

struct SingleItemEdit: View {
    
    var name: String
    @Binding var value: Float
    
    var numberFormatter: NumberFormatter
    
    init(name: String, value: Binding<Float>) {
        self.name = name
        self._value = value
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
    }
    
    var body: some View {
        Section {
            
            HStack {
                Text(name)
                TextField("", value: $value, formatter: numberFormatter)
                    .frame(width: 20)
                Stepper(value: $value, step: 0.1) {
                    EmptyView()
                }
            }
        }
    }
}
