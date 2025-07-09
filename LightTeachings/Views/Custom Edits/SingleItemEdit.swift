import SwiftUI

struct SingleItemEdit: View {
    
    // Name
    var name: String
    
    // Value
    @Binding var value: Float
    
    // Optional range for the edit
    var range: ClosedRange<Float>?
    
    // Just needs the name and value
    init(name: String, value: Binding<Float>, range: ClosedRange<Float>? = nil) {
        
        // Set the name and value
        self.name = name
        self._value = value
        
        // Set the range
        self.range = range
    }
    
    var body: some View {
        Section {
            HStack {
                
                // Name and number edit
                Text(name)
                NumberEdit(value: $value, range: range)
            }
        }
    }
}
