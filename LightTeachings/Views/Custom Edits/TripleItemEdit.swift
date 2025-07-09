import SwiftUI

struct TripleItemEdit: View {
    
    // Name of edit
    let name: String
    
    // Names of all inputs
    let inputOneName: String
    let inputTwoName: String
    let inputThreeName: String
    
    // Value inside of a vec4
    @Binding var value: SIMD4<Float>
    
    // MARK: -Probally not good to share this-
    // State variable for expanded disclosures
    @State private var disclosureIsExpanded = true
    
    init(name: String, inputOneName: String = "X", inputTwoName: String = "Y", inputThreeName: String = "Z", value: Binding<SIMD4<Float>>) {
        
        // Set names
        self.name = name
        self.inputOneName = inputOneName
        self.inputTwoName = inputTwoName
        self.inputThreeName = inputThreeName
        
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
                        NumberEdit(value: $value[0])
                    }
                    HStack {
                        Text(inputTwoName)
                        NumberEdit(value: $value[1])
                    }
                    HStack {
                        Text(inputThreeName)
                        NumberEdit(value: $value[2])
                    }
                }
            }
        }
    }
}
