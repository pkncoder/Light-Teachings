import SwiftUI

struct MaterialEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Material info
    @Binding var material: MaterialWrapper
    var materialIndex: Int
    
    // Computed Binding for ColorPicker
    var color: Binding<Color> {
        Binding<Color>(
            get: {
                // Convert SIMD4<Float> to Color
                return Color(red: CGFloat(material.albedo.x), green: CGFloat(material.albedo.y), blue: CGFloat(material.albedo.z), opacity: CGFloat(material.albedo.w))
            },
            set: { newColor in
                // Convert Color to SIMD4<Float>
                // Use Color.resolve(in:) to get the color components
                let resolvedColor = newColor.resolve(in: .init()) // You might need a more appropriate EnvironmentValues here
                material.albedo = SIMD4<Float>(resolvedColor.red, resolvedColor.green, resolvedColor.blue, resolvedColor.opacity)
                
                rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: self.materialIndex)
            }
        )
    }
    
    var body: some View {
        List {
            Section("Colors") {
                
                // Albedo
                ColorPicker("Diffuse Color", selection: color, supportsOpacity: false)
                
            }
            
            Section("Material Settings") {
                
                // Material rougness
                SingleItemEdit(name: "Roughness", value: $material.materialSettings[0], slidingSensitivity: 100, range: 0...1)
                
                // Material mettalic amount
                SingleItemEdit(name: "Matallic Index", value: $material.materialSettings[1], slidingSensitivity: 100, range: 0...1)
                
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: material.materialSettings) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if self.rendererSettings.updateData?.updateType == .Full { return }
            
            // Updating the scene tree
            rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: self.materialIndex)
        }
    }
}
