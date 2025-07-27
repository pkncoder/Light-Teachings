import SwiftUI

struct RendererEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Renderer Data binding
    @Binding public var rendererData: RendererDataWrapper
    
    // Computed Binding for ColorPicker
    private var ambientColor: Binding<Color> {
        Binding<Color>(
            get: {
                // Convert SIMD4<Float> to Color
                return Color(red: CGFloat(rendererSettings.sceneWrapper.rendererData.ambient.x), green: CGFloat(rendererSettings.sceneWrapper.rendererData.ambient.y), blue: CGFloat(rendererSettings.sceneWrapper.rendererData.ambient.z), opacity: CGFloat(1))
            },
            set: { newColor in
                // Convert Color to SIMD4<Float>
                // Use Color.resolve(in:) to get the color components
                let resolvedColor = newColor.resolve(in: .init()) // You might need a more appropriate EnvironmentValues here
                rendererSettings.sceneWrapper.rendererData.ambient = SIMD4<Float>(resolvedColor.red, resolvedColor.green, resolvedColor.blue, rendererSettings.sceneWrapper.rendererData.ambient.w)
            }
        )
    }
    
    var body: some View {
        
        List {
            
            Section("Shading Model") {
                
                // Current Shading model
                ShadingModelEdit(model: $rendererData.shadingData[0])
                
                // Shadows override
                ShadowOverrideEdit(shadowSettings: $rendererData.shadingData[1], shadingModel: rendererData.shadingData[0])
                
            }
            
            Section("Render Size") {
                NumberEdit(value: $rendererSettings.renderSize.x, intSliding: true)
                NumberEdit(value: $rendererSettings.renderSize.y, intSliding: true)
            }
            
            Section ("Ambient Coloring") {
                ColorPicker("Ambient Color", selection: ambientColor, supportsOpacity: false)
                NumberEdit(value: $rendererSettings.sceneWrapper.rendererData.ambient.w, range: 0...1)
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: rendererData.shadingData) { oldValue, newValue in
            if rendererSettings.updateData?.updateType == .Full { return }
            
            rendererSettings.updateData = UpdateData(updateType: .Scene, updateIndex: -1)
            
        }
    }
}
