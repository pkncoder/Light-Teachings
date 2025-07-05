import SwiftUI

struct OpenFile: View {
    @EnvironmentObject var rendererSettings: RendererSettings

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
                    self.rendererSettings.filename = panel.url?.lastPathComponent.split(separator: ".").first?.description ?? "<none>"
                    self.rendererSettings.fileUrl = panel.url
                    
                    print(rendererSettings.filename)
                    print(rendererSettings.fileUrl!)
                }
                
                rendererSettings.sceneWrapper = SceneBuilder(rendererSettings.filename).getScene()
                rendererSettings.updateData = UpdateData(updateType: .Full, updateIndex: -1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
