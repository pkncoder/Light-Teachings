import SwiftUI

struct BoxTypeEdit: View {
    
    // Box type binding in float and enum
    @Binding var boxType: Float
    @State var boxTypeEnum: Objects
    
    // Init with the float value of the box type
    init(boxType: Binding<Float>) {
        // Set the box type and get the box type from the index
        self._boxType = boxType
        self.boxTypeEnum = Objects.getObjectFromIndex(boxType.wrappedValue)
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Current Box Form: ")
                Picker(selection: $boxTypeEnum, label: Text("")) {
                    ForEach(Objects.allBoxes, id: \.self) { boxType in
                        Text(boxType.rawValue)
                    }
                }
                .onChange(of: boxTypeEnum) { old, new in
                    // Whenever the box type is change, also change the enum
                    boxType = Objects.getIndexFromObject(new)
                }
            }
        }
    }
}
