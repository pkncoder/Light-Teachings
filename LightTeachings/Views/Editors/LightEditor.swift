import SwiftUI

struct LightEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Light binding
    @Binding public var light: LightWrapper
    @State private var lightClone: LightWrapper
    
    // Light index binding
    public var lightIndex: Int
    
    @State private var skip: Bool = false
    
    // Computed Binding for ColorPicker
    private var albedo: Binding<Color> {
        Binding<Color>(
            get: {
                return Color(red: CGFloat(lightClone.albedo.x), green: CGFloat(lightClone.albedo.y), blue: CGFloat(lightClone.albedo.z), opacity: CGFloat(1))
            },
            set: { newColor in
                let resolvedColor = newColor.resolve(in: .init())
                lightClone.albedo = SIMD4<Float>(resolvedColor.red, resolvedColor.green, resolvedColor.blue, lightClone.albedo.w)
            }
        )
    }
    
    init(light: Binding<LightWrapper>, lightIndex: Int) {
        self._light = light
        self.lightClone = light.wrappedValue
        
        self.lightIndex = lightIndex
    }
    
    var body: some View {
        
        List {
            Section("Position") {
                // Light Origin
                TripleItemEdit(name: "Origin", value: $lightClone.origin)
            }
            
            Section("Light Coloring") {
                ColorPicker("Color", selection: albedo, supportsOpacity: false)
                NumberEdit(value: $lightClone.albedo.w, range: 0...300)
            }
        }
        .listStyle(InsetListStyle())
        .onChange(of: self.lightClone) { old, new in
            if skip {
                skip.toggle()
                return
            } else {
                skip = true
                light = lightClone
                rendererSettings.updateData = UpdateData(updateType: .Light, updateIndex: lightIndex)
            }
        }
        .onChange(of: self.light) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if skip {
                skip.toggle()
                return
            }
            
            skip = true
            lightClone = light
            rendererSettings.updateData = UpdateData(updateType: .Light, updateIndex: lightIndex)
        }
    }
}
