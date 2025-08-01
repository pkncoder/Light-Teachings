import SwiftUI

struct ObjectEditor: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Object info
    @Binding public var object: ObjectWrapper
    @State private var objectClone: ObjectWrapper
    
    public var objectIndex: Int
    
    @State private var skip = false
    
    init(object: Binding<ObjectWrapper>, objectIndex: Int) {
        self._object = object
        self.objectClone = object.wrappedValue
        self.objectIndex = objectIndex
    }
    
    var body: some View {
        
        // TODO: -REPEATED CODE WEEWOOWEEWOO-
        
        // List here for style choices in the other editors
        List {
            
            // This shows what kind of object editor to use
            if (objectClone.objectData[0] == 1) {
                
                // Sphere
                SphereEditor(object: $objectClone)
                
            } else if (objectClone.objectData[0] == 2) {
                
                // Box
                BoxEditor(object: $objectClone)
                
            } else if (objectClone.objectData[0] == 3) {
                
                // Box
                BoxEditor(object: $objectClone)
                
            } else if (objectClone.objectData[0] == 4) {
                
                // Box
                BoxEditor(object: $objectClone)
                
            } else if (objectClone.objectData[0] == 5) {
                
                // Plane
                PlaneEditor(object: $objectClone)
                
            } else if (objectClone.objectData[0] == 6) {
                
                // Cylinder
                CylinderEditor(object: $objectClone)
            }
            
            else {
                Text("Object is invallid or editor is not supported yet")
            }
        }
        .listStyle(InsetListStyle())
        .onAppear {
            
        }
        .onChange(of: self.objectClone) { old, new in
            if skip {
                skip = false
                return
            } else {
                skip = true
                object = objectClone
                rendererSettings.updateData = UpdateData(updateType: .Object, updateIndex: objectIndex)
            }
        }
        .onChange(of: object) { oldValue, newValue in
            
            // If the update data is full, just ignore it so it can flush through
            if skip {
                skip = false
                return
            }
            
            skip = true
            objectClone = object
//            rendererSettings.updateData = UpdateData(updateType: .Object, updateIndex: objectIndex)
        }
    }
}
