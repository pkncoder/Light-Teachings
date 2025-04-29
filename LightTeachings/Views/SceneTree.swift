//
//  SceneTreeView.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 4/29/25.
//

import SwiftUI

struct SceneTree: View {
    
    let sceneBuilder: SceneBuilder
    let sceneWrapper: SceneBuilder.SceneWrapper
    let sceneNodes: SceneBuilder.SceneNode
    
    init() {
        self.sceneBuilder = SceneBuilder("lifeScene")
        
        self.sceneWrapper = sceneBuilder.getScene()
        self.sceneNodes = sceneBuilder.getNodeTree(sceneWrapper: sceneWrapper)
    }
    
    // Here we create a `List` containing an `OutlineGroup` initialized with our data and the path to find children
    var body: some View {
        VStack {
            
            List {
                OutlineGroup(sceneNodes, children: \.children) { node in
                    HStack {
                        Text("\(node.name)")
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .listStyle(SidebarListStyle())
        }
        .padding()
    }
}
