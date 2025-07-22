import Foundation

// Data for an update for the renderer
struct UpdateData: Equatable {
    
    // == method
    public static func == (lhs: UpdateData, rhs: UpdateData) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: UUID
    
    public var updateType: SceneSelectionType
    public var updateIndex: Int
    
    init(updateType: SceneSelectionType, updateIndex: Int) {
        self.id = UUID()
        self.updateType = updateType
        self.updateIndex = updateIndex
    }
}
