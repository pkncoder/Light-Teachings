import SwiftUI

struct SaveFile: View {
    
    // Render Settigngs
    @EnvironmentObject var rendererSettings: RendererSettings

    var body: some View {
        HStack {
            
            // Save a scene
            Button("Save File")
            {
                // Do-catch
                do {
                    
                    // Create the save pannel
                    let savePanel = NSSavePanel()
                    
                    // Set attributes
                    savePanel.allowedContentTypes = [.json]
                    savePanel.canCreateDirectories = false
                    
                    savePanel.directoryURL = URL(fileURLWithPath: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).description)
                    
                    savePanel.title = "Save the scene file"
                    savePanel.message = "Choose where to save the file"
                    savePanel.prompt = "Save"
                    
                    savePanel.nameFieldLabel = "File name:"
                    savePanel.nameFieldStringValue = self.rendererSettings.filename
                    
                    // Run the modal, and if it finishes with a 200 exit code / OK the coninue
                    if savePanel.runModal() == .OK {
                        rendererSettings.fileUrl = savePanel.url
                        self.rendererSettings.filename = savePanel.url?.lastPathComponent ?? "<none>"
                    }
                    
                    // Try to write to the file
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
