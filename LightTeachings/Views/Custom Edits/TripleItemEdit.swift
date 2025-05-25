import SwiftUI

struct TripleItemEdit: View {
    
    let name: String
    
    let inputOneName: String
    let inputTwoName: String
    let inputThreeName: String
    
    @Binding var value: SIMD4<Float>
    
    var numberFormatter: NumberFormatter
    
    @State private var disclosureIsExpanded = true
    
    init(name: String, inputOneName: String = "X", inputTwoName: String = "Y", inputThreeName: String = "Z", value: Binding<SIMD4<Float>>) {
        self.name = name
        
        self.inputOneName = inputOneName
        self.inputTwoName = inputTwoName
        self.inputThreeName = inputThreeName
        
        self._value = value
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
    }
    
    var body: some View {
        Section {
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
