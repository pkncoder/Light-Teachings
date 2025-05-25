import SwiftUI
struct NumberEdit: View {
    @Binding public var value: Float
    
    private var stepperSensitivity: Float = 0.1
    private var slidingSensitivity: Float = 1.0
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    @FocusState private var isFocused: Bool
    @StateObject var numberStates: NumberSliderState = NumberSliderState()
    
    init(value: Binding<Float>, stepperSensitivity: Float = 1, slidingSensitivity: Float = 50) {
        self._value = value
        self.stepperSensitivity = stepperSensitivity
        self.slidingSensitivity = slidingSensitivity
    }
    
    var body: some View {
        
        HStack {
            
            Button("-") {
                value -= stepperSensitivity
            }
            .padding(0)
            
            if numberStates.myValue {
                TextField("", value: $value, formatter: self.numberFormatter)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        numberStates.toggleMyValue()
                    }
                    .frame(width: 40)
                    .lineLimit(1)
            } else {
                Text(String(format: "%.1f", value))
                    .gesture(
                        DragGesture(minimumDistance: 1.0, coordinateSpace: .local)
                            .onChanged { coord in
                                let deltaX = Float(coord.location.x) - numberStates.lastDeltaX
                                
                                value += deltaX / slidingSensitivity
                                
                                numberStates.updateValueX(newDeltaX: Float(coord.location.x))
                            }
                            .onEnded({ _ in
                                numberStates.updateValueX(newDeltaX: 0.0)
                            })
                    )
                    .onTapGesture(count: 2) {
                        numberStates.toggleMyValue()
                    }
                    .frame(width: 40)
                    .lineLimit(1)
            }
            
            Button("+") {
                value += stepperSensitivity
            }
            .padding(0)
        }
        .background(Color.gray.opacity(0.2))
        .padding(0)
    }
}

class NumberSliderState: ObservableObject {
    @Published var myValue: Bool = false
    @Published var lastDeltaX: Float = 0.0

    func toggleMyValue() {
        myValue.toggle()
    }
    
    func updateValueX(newDeltaX: Float) {
        DispatchQueue.main.async {
            self.lastDeltaX = newDeltaX
        }
    }
}
