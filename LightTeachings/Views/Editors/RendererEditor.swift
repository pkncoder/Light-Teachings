import SwiftUI

struct RendererEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Renderer Data binding
    @Binding public var rendererData: RendererDataWrapper
    
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
        }
        .listStyle(InsetListStyle())
        .onChange(of: rendererData.shadingData) { oldValue, newValue in
            if rendererSettings.updateData?.updateType == .Full { return }
            
            rendererSettings.updateData = UpdateData(updateType: .Scene, updateIndex: -1)
            
        }
    }
}
