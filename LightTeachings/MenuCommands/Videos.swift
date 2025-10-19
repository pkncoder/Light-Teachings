import SwiftUI

struct YoutubeLinksCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appVisibility) {  // Places group after the Help menu
            Menu("Tutorials") {
                
                // Each of these opens a different video in the browser
                Link("What is Ray Tracing and where is it Used?", destination: URL(string: "https://www.youtube.com/watch?v=XXXXX")!)
                Link("How does Ray Tracing Work?", destination: URL(string: "https://www.youtube.com/watch?v=XXXXX")!)
                Link("Concepts", destination: URL(string: "https://www.youtube.com/watch?v=XXXXX")!)
                Link("How to Hit Objects and return a Picture?", destination: URL(string: "https://www.youtube.com/watch?v=XXXXX")!)
                Link("Simple Diffuse Lighting Model", destination: URL(string: "https://www.youtube.com/watch?v=XXXXX")!)
            }
        }
    }
}
