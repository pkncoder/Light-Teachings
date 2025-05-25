import SwiftUI

struct MaterialEditor: View {
    
    @EnvironmentObject var appState: AppState
    @State var material: SceneBuilder.MaterialWrapper
    
    init (materialIndex: Int) {
        @EnvironmentObject var appState: AppState
        self.material = appState.sceneWrapper.materials[materialIndex + Int(appState.sceneWrapper.lengths[0])]
    }
    
    var body: some View {
        VStack {
            Text("\(self.appState.sceneWrapper.materials[self.appState.sceneWrapper.materials.count - 1])")
        }
    }
}
