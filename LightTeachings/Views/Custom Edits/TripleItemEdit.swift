import SwiftUI

struct TripleItemEdit: View {
    
    // Name of edit
    public let name: String
    
    // Names of all inputs
    public let inputOneName: String
    public let inputTwoName: String
    public let inputThreeName: String
    
    private let slidingSensitivity: Float
    private let range: ClosedRange<Float>?
    
    // Value inside of a vec4
    @Binding public var value: SIMD4<Float>
    
    // MARK: -Probally not good to share this-
    // State variable for expanded disclosures
    @State private var disclosureIsExpanded = true
    
    init(name: String, inputOneName: String = "X", inputTwoName: String = "Y", inputThreeName: String = "Z", value: Binding<SIMD4<Float>>, slidingSensitivity: Float = 50, range: ClosedRange<Float>? = nil) {
        
        // Set names
        self.name = name
        self.inputOneName = inputOneName
        self.inputTwoName = inputTwoName
        self.inputThreeName = inputThreeName
        
        self.slidingSensitivity = slidingSensitivity
        self.range = range
        
        // Set value
        self._value = value
    }
    
    var body: some View {
        Section {
            
            // Disclosure group with 3 number edits
            DisclosureGroup(name, isExpanded: $disclosureIsExpanded) {
                VStack {
                    HStack {
                        Text(inputOneName)
                        NumberEdit(value: $value[0], slidingSensitivity: slidingSensitivity, range: range)
                    }
                    HStack {
                        Text(inputTwoName)
                        NumberEdit(value: $value[1], slidingSensitivity: slidingSensitivity, range: range)
                    }
                    HStack {
                        Text(inputThreeName)
                        NumberEdit(value: $value[2], slidingSensitivity: slidingSensitivity, range: range)
                    }
                }
            }
        }
    }
}
