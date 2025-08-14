import SwiftUI

struct MaterialEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Material info
    @Binding public var material: MaterialWrapper
    @State private var materialClone: MaterialWrapper
    
    public var materialIndex: Int
    
    @State private var skip = false
    
    init(material: Binding<MaterialWrapper>, materialIndex: Int) {
        self._material = material
        self.materialClone = material.wrappedValue
        self.materialIndex = materialIndex
    }
    
    // Computed Binding for ColorPicker
    private var color: Binding<Color> {
        Binding<Color>(
            get: {
                // Convert SIMD4<Float> to Color
                return Color(red: CGFloat(materialClone.albedo.x), green: CGFloat(materialClone.albedo.y), blue: CGFloat(materialClone.albedo.z), opacity: CGFloat(material.albedo.w))
            },
            set: { newColor in
                // Convert Color to SIMD4<Float>
                // Use Color.resolve(in:) to get the color components
                let resolvedColor = newColor.resolve(in: .init()) // You might need a more appropriate EnvironmentValues here
                materialClone.albedo = SIMD4<Float>(resolvedColor.red, resolvedColor.green, resolvedColor.blue, resolvedColor.opacity)
                
//                rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: self.materialIndex)
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
                SingleItemEdit(name: "Roughness", value: $materialClone.materialSettings[0], slidingSensitivity: 100, range: 0...1)
                
                // Material mettalic amount
                SingleItemEdit(name: "Matallic Index", value: $materialClone.materialSettings[1], slidingSensitivity: 100, range: 0...1)
                
            }
            
            Section("Transparency") {
                
                // Material rougness
                SwitchEdit(name: "Transparent", value: $materialClone.transparency[0])
                
                // Material mettalic amount
                SingleItemEdit(name: "IOR", value: $materialClone.transparency[1], slidingSensitivity: 100, range: 0...1)
                
            }
            .disabled(true)
            .foregroundColor(.secondary)
            .help("Disabled due to instability.")
            
            Section("Reflecticity") {
                
                // Material rougness
                SwitchEdit(name: "Reflective", value: $materialClone.reflecticity[0])
                
            }
            .disabled(true)
            .foregroundColor(.secondary)
            .help("Disabled due to instability.")
        }
        .listStyle(InsetListStyle())
        .onChange(of: self.materialClone) { old, new in
            if skip {
                skip.toggle()
                return
            } else {
                skip = true
                material = materialClone
                rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: materialIndex)
            }
        }
        .onChange(of: material) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if skip {
                skip.toggle()
                return
            }
            
            skip = true
            materialClone = material
            rendererSettings.updateData = UpdateData(updateType: .Material, updateIndex: materialIndex)
        }
    }
}
