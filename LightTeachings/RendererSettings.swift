import SwiftUI

class RendererSettings: ObservableObject, Equatable, Identifiable {
    static func == (lhs: RendererSettings, rhs: RendererSettings) -> Bool {
        return lhs.sceneWrapper == rhs.sceneWrapper
    }
    
    @Published var sceneWrapper: SceneBuilder.SceneWrapper
    
    @Published var filename: String = ""
    @Published var fileUrl: URL? = nil
    
    @Published var updateData: UpdateData? = nil
    
    init(sceneWrapper: SceneBuilder.SceneWrapper) {
        self._sceneWrapper = Published(wrappedValue: sceneWrapper)
    }
}
