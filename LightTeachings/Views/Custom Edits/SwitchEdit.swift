import SwiftUI

struct SwitchEdit: View {
    
    // Name
    public var name: String
    
    // Value
    @Binding public var value: Float
    @State private var bool: Bool
    
    // Just needs the name and value
    init(name: String, value: Binding<Float>) {
        
        // Set the name and value
        self.name = name
        self._value = value
        
        self.bool = value.wrappedValue == 0 ? false : true
    }
    
    var body: some View {
        Section {
            HStack {
                
                // Name and number edit
                Toggle(name, isOn: $bool)
                    .onChange(of: bool) { oldValue, newValue in
                        value = newValue ? 1 : 0
                    }
            }
        }
    }
}
