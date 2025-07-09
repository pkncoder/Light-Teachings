import SwiftUI

class RendererSettings: ObservableObject, Equatable, Identifiable {
    
    // Check scene wrappers for equality
    static func == (lhs: RendererSettings, rhs: RendererSettings) -> Bool {
        return lhs.sceneWrapper == rhs.sceneWrapper
    }
    
    // Most recent scene wrapper
    @Published var sceneWrapper: SceneBuilder.SceneWrapper
    
    // Scene  file info
    @Published var filename: String = ""
    @Published var fileUrl: URL? = nil
    
    // Update info
    @Published var updateData: UpdateData? = nil
    
    // Only thing needed is the scene wrapper for init
    init(sceneWrapper: SceneBuilder.SceneWrapper) {
        self._sceneWrapper = Published(wrappedValue: sceneWrapper)
    }
}
