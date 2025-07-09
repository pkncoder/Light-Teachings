import SwiftUI

struct SingleItemEdit: View {
    
    var name: String
    @Binding var value: Float
    
    var numberFormatter: NumberFormatter
    
    var range: ClosedRange<Float>?
    
    init(name: String, value: Binding<Float>, range: ClosedRange<Float>? = nil) {
        self.name = name
        self._value = value
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        
        self.range = range
    }
    
    var body: some View {
        Section {
            
            HStack {
                Text(name)
                NumberEdit(value: $value, range: range)
            }
        }
    }
}
