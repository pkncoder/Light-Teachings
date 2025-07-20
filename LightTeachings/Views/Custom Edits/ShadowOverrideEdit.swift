import SwiftUI

struct ShadowOverrideEdit: View {
    @Binding public var shadowSettings: Float
    public var shadingModel: Float
    
    @State private var shadowOverride: Bool = false
    @State private var shadowsOn: Bool = false
    
    var body: some View {
        Toggle("Shadow Override", isOn: $shadowOverride)
            .onChange(of: shadowOverride) { old, new in
                shadowSettings = new ? 1 : 0
            }
        Toggle("Shadows On", isOn: $shadowsOn)
            .onChange(of: shadowsOn) { old, new in
                shadowSettings = new ? 2 : 1
            }
            .disabled(!shadowOverride)
            
    }
}
