import SwiftUI

class RendererSettings: ObservableObject, Equatable, Identifiable {
    
    // Check scene wrappers for equality
    public static func == (lhs: RendererSettings, rhs: RendererSettings) -> Bool {
        return lhs.sceneWrapper == rhs.sceneWrapper
    }
    
    // Most recent scene wrapper
    @Published public var sceneWrapper: SceneWrapper
    @Published public var renderSize: SIMD2<Float> = .init(300, 300)
    
    // Scene  file info
    @Published public var filename: String = ""
    @Published public var fileUrl: URL? = nil
    
    // Update info
    @Published public var updateData: UpdateData? = nil
    
    // Scene tree node
    @Published public var sceneNodes: SceneNode? = nil
    
    @Published public var doIt: Bool = true
    
    // Only thing needed is the scene wrapper for init
    init(sceneWrapper: SceneWrapper) {
        self._sceneWrapper = Published(wrappedValue: sceneWrapper)
    }
}
