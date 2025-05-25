import SwiftUI

struct SaveFile: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            Button("Open...")
            {
                do {
                    let savePanel = NSSavePanel()
                    
                    savePanel.allowedContentTypes = [.json]
                    savePanel.canCreateDirectories = false
                    
                    savePanel.title = "Save the scene file"
                    savePanel.message = "Choose where to save the file"
                    savePanel.prompt = "Save"
                    
                    savePanel.nameFieldLabel = "File name:"
                    savePanel.nameFieldStringValue = self.appState.filename
                    
                    if savePanel.runModal() == .OK {
                        appState.fileUrl = savePanel.url
                        self.appState.filename = savePanel.url?.lastPathComponent ?? "<none>"
                    }
                    
                    print(appState.filename)
                    
                    let data = try JSONEncoder().encode(appState.sceneWrapper)
                    try data.write(to: appState.fileUrl!)
                } catch {
                    print("Error while saving file: \(error)")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
