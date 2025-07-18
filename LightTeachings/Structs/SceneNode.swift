import SwiftUI

// Scene node for the scene tree
struct SceneNode: Hashable, Identifiable {
    
    // Id
    public var id: Self { self }
    
    // Name
    public var name: String
    
    // Data in the node
    public var selectionData: SceneSelectionData?
    
    // Children
    public var children: [SceneNode]? = nil
    
    // Initializer
    public init(name: String, sceneSelectionType: SceneSelectionType? = nil, index: Int? = nil, children: [SceneNode]? = nil) {
        self.name = name
        self.selectionData = SceneSelectionData(selectedIndex: index, selectionType: sceneSelectionType)
        self.children = children
    }
}
