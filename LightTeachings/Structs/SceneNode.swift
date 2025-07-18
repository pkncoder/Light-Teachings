import SwiftUI

// Scene node for the scene tree
struct SceneNode: Hashable, Identifiable {
    
    // Id
    var id: Self { self }
    
    // Name
    var name: String
    
    // Data in the node
    var selectionData: SceneSelectionData?
    
    // Children
    var children: [SceneNode]? = nil
    
    // Initializer
    init(name: String, sceneSelectionType: SceneSelectionType? = nil, index: Int? = nil, children: [SceneNode]? = nil) {
        self.name = name
        self.selectionData = SceneSelectionData(selectedIndex: index, selectionType: sceneSelectionType)
        self.children = children
    }
}
