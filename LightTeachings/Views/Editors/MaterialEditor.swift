import SwiftUI

struct MaterialEditor: View {
    
    @Binding var material: SceneBuilder.MaterialWrapper
    
    var body: some View {
        VStack {
            Text("\(material.description)")
        }
    }
}
