import SwiftUI

struct SingleItemEdit: View {
    
    // Name
    public var name: String
    
    // Value
    @Binding public var value: Float
    
    private var slidingSensitivity: Float
    
    // Sliders are set to ints
    private var intSliding: Bool
    
    // Optional range for the edit
    private var range: ClosedRange<Float>?
    
    // Just needs the name and value
    init(name: String, value: Binding<Float>, slidingSensitivity: Float = 50, intSliding: Bool = false, range: ClosedRange<Float>? = nil) {
        
        // Set the name and value
        self.name = name
        self._value = value
        
        self.slidingSensitivity = slidingSensitivity
        
        // Set the int sliding setting
        self.intSliding = intSliding
        
        // Set the range
        self.range = range
    }
    
    var body: some View {
        Section {
            HStack {
                
                // Name and number edit
                Text(name)
                NumberEdit(value: $value, slidingSensitivity: slidingSensitivity, intSliding: intSliding, range: range)
            }
        }
    }
}
