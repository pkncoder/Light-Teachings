import SwiftUI

struct ObjectTypeEdit: View {
    
    // Opperation w/ the enum
    @Binding public var objectType: Float
    @State private var objectEnum: Objects
    
    // Init with the float value of the opperation
    init(objectType: Binding<Float>) {
        
        // Set the operation and the equal operation in an enum
        self._objectType = objectType
        self.objectEnum = Objects.getObjectFromIndex(objectType.wrappedValue)
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Current Type: ")
                Picker(selection: $objectEnum, label: Text("")) {
                    ForEach(Objects.availableObjects, id: \.self) { object in
                        Text(object.rawValue)
                    }
                }
                .onChange(of: objectEnum) { old, new in
                    // Whenever the opperation enum is set, also set the operation
                    objectType = Objects.getIndexFromObject(new)
                }
            }
        }
    }
}
