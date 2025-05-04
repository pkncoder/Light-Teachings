import SwiftUI

struct OpperationEdit: View {
    
    @Binding var opperation: Float
    @State var opperationEnum: Opperations
    
    init(opperation: Binding<Float>) {
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
                    opperation = Opperations.getIndexFromOpperation(new)
                }
            }
        }
    }
}
