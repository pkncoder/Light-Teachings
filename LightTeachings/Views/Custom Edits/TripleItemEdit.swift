import SwiftUI

struct TripleItemEdit: View {
    
    let name: String
    
    let inputOneName: String
    let inputTwoName: String
    let inputThreeName: String
    
    @Binding var coordinate: SIMD4<Float>
    
    var numberFormatter: NumberFormatter
    
    init(name: String, inputOneName: String = "X", inputTwoName: String = "Y", inputThreeName: String = "Z", coordinate: Binding<SIMD4<Float>>) {
        self.name = name
        
        self.inputOneName = inputOneName
        self.inputTwoName = inputTwoName
        self.inputThreeName = inputThreeName
        
        self._coordinate = coordinate
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
    }
    
    var body: some View {
        Section {
            DisclosureGroup(name) {
                VStack {
                    HStack {
                        Text(inputOneName)
                        TextField("", value: $coordinate[0], formatter: numberFormatter)
                            .frame(width: 20)
                        Stepper(value: $coordinate[0], step: 0.1) {
                            EmptyView()
                        }
                    }
                    HStack {
                        Text(inputTwoName)
                        TextField("", value: $coordinate[1], formatter: numberFormatter)
                            .frame(width: 20)
                        Stepper(value: $coordinate[1], step: 0.1) {
                            EmptyView()
                        }
                    }
                    HStack {
                        Text(inputThreeName)
                        TextField("", value: $coordinate[2], formatter: numberFormatter)
                            .frame(width: 20)
                        Stepper(value: $coordinate[2], step: 0.1) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}
