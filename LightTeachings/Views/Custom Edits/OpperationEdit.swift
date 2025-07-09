import SwiftUI

struct OpperationEdit: View {
    
    // Opperation w/ the enum
    @Binding var opperation: Float
    @State var opperationEnum: Opperations
    
    // Init with the float value of the opperation
    init(opperation: Binding<Float>) {
        
        // Set the operation and the equal operation in an enum
        self._opperation = opperation
        self.opperationEnum = Opperations.getOpperationFromIndex(opperation.wrappedValue)
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Current Opperation: ")
                Picker(selection: $opperationEnum, label: Text("")) {
                    ForEach(Opperations.allCases, id: \.self) { opperation in
                        Text(opperation.rawValue)
                    }
                }
                .onChange(of: opperationEnum) { old, new in
                    // Whenever the opperation enum is set, also set the operation
                    opperation = Opperations.getIndexFromOpperation(new)
                }
            }
        }
    }
}
