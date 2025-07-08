import SwiftUI

struct MaterialEditor: View {
    
    @EnvironmentObject var rendererSettings: RendererSettings
    @Binding var material: SceneBuilder.MaterialWrapper
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
                
                ColorPicker("Diffuse Color", selection: color, supportsOpacity: false)
                
            }
            
            Section("Material Settings") {
                
                SingleItemEdit(name: "Roughness", value: $material.materialSettings[0])
                SingleItemEdit(name: "Matallic Index", value: $material.materialSettings[1])
                
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: material.materialSettings) { oldValue, newValue in
            rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: self.materialIndex)
        }
    }
}
