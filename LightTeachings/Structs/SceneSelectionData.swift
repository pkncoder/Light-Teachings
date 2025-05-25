import Foundation

struct SceneSelectionData: Equatable, Hashable {
    var selectedIndex: Int?
    var selectionType: SceneSelectionType?
}

enum SceneSelectionType {
    case Object
    case Material
    case Light
}
