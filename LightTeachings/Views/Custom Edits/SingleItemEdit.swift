import SwiftUI

struct SingleItemEdit: View {
    
    // Name
    var name: String
    
    // Value
    @Binding var value: Float
    
    private var slidingSensitivity: Float
    
    // Optional range for the edit
    var range: ClosedRange<Float>?
    
    // Just needs the name and value
    init(name: String, value: Binding<Float>, slidingSensitivity: Float = 50, range: ClosedRange<Float>? = nil) {
        
        // Set the name and value
        self.name = name
        self._value = value
        
        self.slidingSensitivity = slidingSensitivity
        
        // Set the range
        self.range = range
    }
    
    var body: some View {
        Section {
            HStack {
                
                // Name and number edit
                Text(name)
                NumberEdit(value: $value, slidingSensitivity: slidingSensitivity, range: range)
            }
        }
    }
}
