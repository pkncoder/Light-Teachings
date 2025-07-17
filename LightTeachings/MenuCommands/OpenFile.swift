import SwiftUI

struct OpenFile: View {
    
    // Render settings
    @EnvironmentObject var rendererSettings: RendererSettings

    var body: some View {
        HStack {
            // Open into a new scene file
            Button("Open...")
            {
                // Build pannel
                let panel = NSOpenPanel()
                
                // Set attributes
                panel.allowsMultipleSelection = false
                panel.allowedContentTypes = [.json]
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                
                // Run the modal, and if it finishes with a 200 exit code / OK the coninue
                if panel.runModal() == .OK {
                    self.rendererSettings.filename = panel.url?.lastPathComponent.split(separator: ".").first?.description ?? "<none>" // Set the file name
                    self.rendererSettings.fileUrl = panel.url // Set the url from the panel
                }
                
                // Get a new scene wrapper and update scene nodes
                rendererSettings.sceneWrapper = SceneBuilder(rendererSettings.fileUrl!).getScene()
                rendererSettings.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: rendererSettings.sceneWrapper)
                
                // Create a new update data / ticket for a full rebuild
                rendererSettings.updateData = UpdateData(updateType: .Full, updateIndex: -1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
