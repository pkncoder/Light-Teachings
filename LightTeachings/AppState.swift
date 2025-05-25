import SwiftUI

class AppState: ObservableObject, Equatable, Identifiable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        return lhs.sceneWrapper == rhs.sceneWrapper
    }
    
    @Published var sceneWrapper: SceneBuilder.SceneWrapper
    
    @Published var filename: String = ""
    @Published var fileUrl: URL? = nil
    
    func changeFileName() {
        filename = filename + "T"
        objectWillChange.send()
    }
    
    init(sceneWrapper: SceneBuilder.SceneWrapper) {
        self._sceneWrapper = Published(wrappedValue: sceneWrapper)
    }
}
