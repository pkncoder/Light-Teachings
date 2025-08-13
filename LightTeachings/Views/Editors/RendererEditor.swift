import SwiftUI

struct RendererEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Renderer Data binding
    @Binding public var rendererData: RendererDataWrapper
    @State private var rendererDataClone: RendererDataWrapper
    
    @State private var skip: Bool = false
    
    @State private var skyBool: Bool
    @State private var AAOn: Bool
    
    // Computed Binding for ColorPicker
    private var ambientColor: Binding<Color> {
        Binding<Color>(
            get: {
                return Color(red: CGFloat(rendererDataClone.ambient.x), green: CGFloat(rendererDataClone.ambient.y), blue: CGFloat(rendererDataClone.ambient.z), opacity: CGFloat(1))
            },
            set: { newColor in
                let resolvedColor = newColor.resolve(in: .init())
                rendererDataClone.ambient = SIMD4<Float>(resolvedColor.red, resolvedColor.green, resolvedColor.blue, rendererDataClone.ambient.w)
            }
        )
    }
    
    init(rendererData: Binding<RendererDataWrapper>) {
        self._rendererData = rendererData
        self.rendererDataClone = rendererData.wrappedValue
        
        self.skyBool = rendererData.wrappedValue.shadingData.w == Float(0.0) ? false : true
        self.AAOn = rendererData.wrappedValue.shadingData.x == Float(0.0) ? false : true
    }
    
    var body: some View {
        
        List {
            
            Section("Shading Model") {
                
                // Current Shading model
                ShadingModelEdit(model: $rendererDataClone.shadingData[0])
                
                // Shadows override
                ShadowOverrideEdit(shadowSettings: $rendererDataClone.shadingData[1], shadingModel: rendererDataClone.shadingData[0])
                
            }
            
            Section("Camera") {
                
                // Ray origin
                TripleItemEdit(name: "Camera Origin", value: $rendererDataClone.camera1)
                
                // Feild of Vision / View
                SingleItemEdit(name: "FOV", value: $rendererDataClone.camera1.w)
            }
            
            Section("Render Size") {
                SingleItemEdit(name: "Width Resolution", value: $rendererSettings.renderSize.x, intSliding: true)
                SingleItemEdit(name: "Height Resolution", value: $rendererSettings.renderSize.y, intSliding: true)
            }
            
            Section ("Ambient Coloring") {
                ColorPicker("Ambient Color", selection: ambientColor, supportsOpacity: false)
                SingleItemEdit(name: "Ambient Strength", value: $rendererDataClone.ambient.w, range: 0...1)
            }
            
            Section("Fake Sky") {
                Toggle("Sky On", isOn: $skyBool)
                    .onChange(of: skyBool) { old, new in
                        rendererDataClone.shadingData.w = new ? 1 : 0
                    }
            }
            
            Section("Anti-Aliasing (Jitter)") {
                Toggle("AA On", isOn: $AAOn)
                    .onChange(of: AAOn) { old, new in
                        rendererDataClone.shadingData.z = new ? 1 : 0
                    }
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: self.rendererDataClone) { old, new in
            if skip {
                skip.toggle()
                return
            } else {
                skip = true
                rendererData = rendererDataClone
                rendererSettings.updateData = UpdateData(updateType: .Scene, updateIndex: -1)
            }
        }
        .onChange(of: rendererData) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if skip {
                skip.toggle()
                return
            }
            
            skip = true
            rendererDataClone = rendererData
            rendererSettings.updateData = UpdateData(updateType: .Scene, updateIndex: -1)
        }
    }
}
