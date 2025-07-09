import SwiftUI

struct NumberEdit: View {
    
    // Value to be changed
    @Binding public var value: Float
    
    // Step amount by the steppers
    private var step: Float
    
    // Sensitivity on the slider
    private var slidingSensitivity: Float
    
    // Tryncate to ints or no
    private var intSliding: Bool
    
    // Number formatter
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    // Focus state for the text feild
    @FocusState private var isFocused: Bool
    
    // Number slider state
    @StateObject var numberSliderState: NumberSliderState = NumberSliderState()
    
    // Range for the number
    var range: ClosedRange<Float>?
    
    // Init, just needs value. Step, sensitivity, int sliding, and range are all optional
    init(value: Binding<Float>, step: Float = 1, slidingSensitivity: Float = 50, intSliding: Bool = false, range: ClosedRange<Float>? = nil) {
        self._value = value
        self.step = step
        self.slidingSensitivity = slidingSensitivity
        self.intSliding = intSliding
        self.range = range
    }
    
    var body: some View {
        
        HStack {
            
            // Minus stepper
            Button("-") {
                // Change the value by step
                value -= step
                
                // If needed, clamp the value
                if let numRange = self.range {
                    value = min(max(value, numRange.lowerBound), numRange.upperBound)
                }
            }
            .padding(0)
            
            // If the typing is enabled use a text feild
            if numberSliderState.myValue {
                TextField("", value: $value, formatter: self.numberFormatter)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        numberSliderState.toggleMyValue()
                    }
                    .frame(width: 40)
                    .lineLimit(1)
            } else {
                // If not focused into the text feild use just regular text
                Text(self.intSliding ? String(format: "%.0f", value) : String(format: "%.2f", value)) // If int sliding, show an int, else show 2 decimal points
                    .gesture(
                        DragGesture(minimumDistance: 1.0, coordinateSpace: .local) // Drag jesture for a slider
                            .onChanged { coord in
                                
                                // Delta X for the coordinate location
                                let deltaX = Float(coord.location.x) - numberSliderState.lastDeltaX
                                
                                // Truncate the sliding if needed
                                if (self.intSliding) {
                                    value += Float(Int(deltaX / slidingSensitivity))
                                } else {
                                    value += deltaX / slidingSensitivity
                                }
                                
                                // If needed, clamp the value
                                if let numRange = self.range {
                                    value = min(max(value, numRange.lowerBound), numRange.upperBound)
                                }
                                
                                // Update delta x
                                numberSliderState.updateValueX(newDeltaX: Float(coord.location.x))
                            }
                            .onEnded({ _ in // When finished, update delta x to 0
                                numberSliderState.updateValueX(newDeltaX: 0.0)
                            })
                    )
                    .onTapGesture(count: 2) { // Double click, get ready for the text feild
                        numberSliderState.toggleMyValue()
                    }
                    .frame(width: 40)
                    .lineLimit(1)
            }
            
            // Adding stepper
            Button("+") {
                
                // Add to value by step
                value += step
                
                // If needed, clamp the value
                if let numRange = self.range {
                    value = min(max(value, numRange.lowerBound), numRange.upperBound)
                }
            }
            .padding(0)
        }
        .background(Color.gray.opacity(0.2))
        .padding(0)
    }
}

// Number slider state for values that need to be saved
class NumberSliderState: ObservableObject {
    @Published var myValue: Bool = false // Text feild focus-like state
    @Published var lastDeltaX: Float = 0.0 // Delta x save for the slider

    // Toggle for text feild
    func toggleMyValue() {
        myValue.toggle()
    }
    
    // Delta X update
    func updateValueX(newDeltaX: Float) {
        DispatchQueue.main.async {
            self.lastDeltaX = newDeltaX
        }
    }
}
