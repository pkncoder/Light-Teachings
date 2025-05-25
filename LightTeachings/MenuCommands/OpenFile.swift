import SwiftUI

struct OpenFile: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            Button("Open...")
            {
                let panel = NSOpenPanel()
                
                panel.allowsMultipleSelection = false
                panel.allowedContentTypes = [.json]
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                
                if panel.runModal() == .OK {
                    self.appState.filename = panel.url?.lastPathComponent ?? "<none>"
                    self.appState.fileUrl = panel.url
                }
                
                appState.sceneWrapper = SceneBuilder(appState.filename).getScene()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
