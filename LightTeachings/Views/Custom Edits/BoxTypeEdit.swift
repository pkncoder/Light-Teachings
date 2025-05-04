import SwiftUI

struct BoxTypeEdit: View {
    
    @Binding var boxType: Float
    @State var boxTypeEnum: Objects
    
    init(boxType: Binding<Float>) {
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
                    boxType = Objects.getIndexFromObject(new)
                }
            }
        }
    }
}
