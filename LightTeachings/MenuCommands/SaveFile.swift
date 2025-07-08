import SwiftUI

struct SaveFile: View {
    @EnvironmentObject var rendererSettings: RendererSettings

    var body: some View {
        HStack {
            Button("Save File")
            {
                do {
                    let savePanel = NSSavePanel()
                    
                    savePanel.allowedContentTypes = [.json]
                    savePanel.canCreateDirectories = false
                    
                    savePanel.directoryURL = URL(fileURLWithPath: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).description)
                    
                    savePanel.title = "Save the scene file"
                    savePanel.message = "Choose where to save the file"
                    savePanel.prompt = "Save"
                    
                    savePanel.nameFieldLabel = "File name:"
                    savePanel.nameFieldStringValue = self.rendererSettings.filename
                    
                    if savePanel.runModal() == .OK {
                        rendererSettings.fileUrl = savePanel.url
                        self.rendererSettings.filename = savePanel.url?.lastPathComponent ?? "<none>"
                    }
                    
                    print(rendererSettings.filename)
                    
                    let data = try JSONEncoder().encode(rendererSettings.sceneWrapper)
                    try data.write(to: rendererSettings.fileUrl!)
                } catch {
                    print("Error while saving file: \(error)")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
