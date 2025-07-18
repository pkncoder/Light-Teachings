import SwiftUI

struct NumberEdit: View {
    
    // Value to be changed
    @Binding public var value: Float
    
    // Step amount by the steppers
    private var step: Float
    
    // Sensitivity amount on the slider (larger == smaller change)
    private var slidingSensitivity: Float
    
    // Truncate to ints or not
    private var intSliding: Bool
    
    // Range for the value to clamp into
    private var range: ClosedRange<Float>?
    
    // Focus state for the text feild
    @FocusState private var isFocused: Bool
    
    // Number slider states
    @State private var lastCoordLocation: Float = 0
    @State private var textEditModeOn: Bool = false
    
    // Number formatter
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    // Init, just **needs** value. Step, sensitivity, int sliding, and range are all optional
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
                // Change the value by the step
                value -= step
            }
            .padding(0)
            
            // If the typing is enabled use a text feild
            if textEditModeOn {
                
                // Text feild that takes in the value and formatter for the number
                TextField("", value: $value, formatter: self.numberFormatter)
                
                    // Slider focus state set to true on appear
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                
                    // On submit of the text feild the textEditMode is flipped to go back to a text box
                    .onSubmit {
                        textEditModeOn.toggle()
                    }
                
                    // Styles
                    .frame(width: 40)
                    .lineLimit(1)
                
            }
            
            else {
                
                // If not focused into the text feild use just regular text
                Text(self.intSliding ? String(format: "%.0f", value) : String(format: "%.2f", value)) // If int sliding is on, show an int, else show 2 decimal points
                    .gesture(
                        DragGesture(minimumDistance: 1.0, coordinateSpace: .local) // Drag gesture for a slider
                            .onChanged { coord in
                                
                                // Get the change in X mouse pos
                                let deltaX = Float(coord.location.x) - lastCoordLocation
                                
                                // Save the new... last coord location
                                lastCoordLocation = Float(coord.location.x)
                                
                                // Change value by the deltaX and sliding sensitivity
                                value += deltaX / slidingSensitivity
                            }
                            .onEnded({ _ in // When finished, reset the last coord location to 0
                                lastCoordLocation = 0.0
                            })
                    )
                    .onTapGesture(count: 2) { // On a double click flip the text edit mode
                        textEditModeOn.toggle()
                    }
                    .frame(width: 40)
                    .lineLimit(1)
            }
            
            // Adding stepper
            Button("+") {
                
                // Add to value by step
                value += step
                
            }
            .padding(0)
        }
        .background(Color.gray.opacity(0.2))
        .padding(0)
        .onChange(of: value) { oldValue, newValue in // Value settings
            
            // If int sliding, truncate value
            if intSliding {
                value = Float(Int(value))
            }
            
            // If a range is set clamp value
            if let numRange = self.range {
                value = min(max(value, numRange.lowerBound), numRange.upperBound)
            }
        }
    }
}
