import SwiftUI

// View that shows all items in the scene, used to select items
struct SceneTree: View {
    
    // Renderer settings
    @EnvironmentObject var rendererSettings: RendererSettings
    
    // Node selection info
    @Binding public var sceneNodeSelection: SceneNode?

    // Initializer
    init(sceneNodeSelection: Binding<SceneNode?>) {
        
        // Set the node selection
        self._sceneNodeSelection = sceneNodeSelection
    }
    
    // Top level body of the SceneTree view
    var body: some View {
        VStack {
            
            // Have a list containing the outline view to stop strange sizing occourances and to make the stlye better
            List(selection: $sceneNodeSelection) { // Hold a selection variable for the outline group
                
                Toggle("Swap", isOn: $rendererSettings.doIt)
                
                // Outline group holds the children of the scene ndoes and displays their names
                if let unwrappedSceneNodes = rendererSettings.sceneNodes {
                    
                    OutlineGroup(unwrappedSceneNodes, children: \.children) { node in
                        
                        // HStack with a spacer to left-align text
                        HStack {
                            
                            if node.selectionData?.selectionType != nil && node.selectionData?.selectionType != .Scene && node.selectionData?.selectionType != .Light {
                                Text("\(node.name)")
                                    .contextMenu {
                                        Button("Delete Item") {
                                            rendererSettings.updateData = UpdateData(updateType: .Full, updateIndex: node.selectionData!.selectedIndex!)
                                            
                                            switch node.selectionData!.selectionType {
                                                case .Object:
                                                rendererSettings.sceneWrapper.rendererData.arrayLengths[0] -= 1
                                                    print(rendererSettings.sceneWrapper.rendererData.arrayLengths[0])
                                                    rendererSettings.sceneWrapper.objects.remove(at: node.selectionData!.selectedIndex!)
                                                case .Material:
                                                    rendererSettings.sceneWrapper.rendererData.arrayLengths[1] -= 1
                                                    rendererSettings.sceneWrapper.materials.remove(at: node.selectionData!.selectedIndex!)
                                                case .Light:
                                                    rendererSettings.sceneWrapper.rendererData.arrayLengths[2] -= 1
                                                default:
                                                    print("This node is not defined.")
                                            }
                                            
                                            
                                            
                                            rendererSettings.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: rendererSettings.sceneWrapper)
                                        }
                                    }
                            }
                            
                            else if node.children?[0].selectionData?.selectionType != nil && node.children![0].selectionData!.selectionType != .Light {
                                Text("\(node.name)")
                                    .contextMenu {
                                        Button("Add Item") {
                                            
                                            
                                            switch node.children![0].selectionData!.selectionType {
                                                case .Object:
                                                    rendererSettings.sceneWrapper.rendererData.arrayLengths[0] += 1
                                                print(rendererSettings.sceneWrapper.rendererData.arrayLengths[0])
                                                rendererSettings.updateData = UpdateData(updateType: .Full, updateIndex: Int(rendererSettings.sceneWrapper.rendererData.arrayLengths[0]))
                                                    rendererSettings.sceneWrapper.objects.append(
                                                        ObjectWrapper(
                                                            origin: SIMD4<Float>(0,0,0,0),
                                                            bounds: SIMD4<Float>(1,1,1,1),
                                                            objectData: SIMD4<Float>(1,0,0,1),
                                                            tempData: SIMD4<Float>(repeating: 0)
                                                        )
                                                    )
                                                print(rendererSettings.sceneWrapper.objects.count)
                                                
                                                case .Material:
                                                    rendererSettings.sceneWrapper.rendererData.arrayLengths[1] += 1
                                                rendererSettings.updateData = UpdateData(updateType: .Full, updateIndex: Int(rendererSettings.sceneWrapper.rendererData.arrayLengths[1]))
                                                    rendererSettings.sceneWrapper.materials.append(
                                                        MaterialWrapper(
                                                            albedo: SIMD4<Float>(1,1,1,0),
                                                            materialSettings: SIMD4<Float>(repeating: 0),
                                                            transparency: SIMD4<Float>(repeating: 0),
                                                            temp2: SIMD4<Float>(repeating: 0)
                                                        )
                                                    )
                                                case .Light:
//                                                    rendererSettings.sceneWrapper.rendererData.arrayLengths[2] += 1
                                                    break
                                                default:
                                                    print("This node is not defined.")
                                            }
                                            
                                            rendererSettings.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: rendererSettings.sceneWrapper)
                                        }
                                    }
                            }
                            
                            else {
                                Text("\(node.name)")
                            }
                            Spacer()
                        }
                    }
                } else {
                    Button("Press Me!") {}
                }
                
                // Top-align the outline group
                Spacer()
            }
            .listStyle(SidebarListStyle())
        }
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        .onAppear() {
            // Get the node tree from the scene builder
            rendererSettings.sceneNodes = SceneBuilder.getNodeTree(sceneWrapper: rendererSettings.sceneWrapper)
        }
    }
}
