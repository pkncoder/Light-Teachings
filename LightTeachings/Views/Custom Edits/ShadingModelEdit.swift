import SwiftUI

struct ShadingModelEdit: View {
    
    // Model w/ the enum
    @Binding public var model: Float
    @State private var modelEnum: ShadingModels
    
    // Init with the float value of the model
    init(model: Binding<Float>) {
        
        // Set the model and the shading model in enum form
        self._model = model
        self.modelEnum = ShadingModels.getModelFromIndex(model.wrappedValue)
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Current Model: ")
                Picker(selection: $modelEnum, label: Text("")) {
                    ForEach(ShadingModels.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                }
                .onChange(of: modelEnum) { old, new in
                    // Whenever the model enum is set, also set the model
                    model = ShadingModels.getIndexFromModel(new)
                }
            }
        }
    }
}
