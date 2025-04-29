//
//  ContentView.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import SwiftUI
import MetalKit







struct ContentView: View {
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var inspectorVisible: Bool = true
    
    var body: some View {

        NavigationSplitView {
            SceneTree()
                
        } detail: {
            HSplitView {
                
                RendererView()
                    .aspectRatio(1, contentMode: .fill)
                
                if inspectorVisible {
                    VStack {
                        Editor()
                            .ignoresSafeArea()
                            .frame(maxWidth: 300)
                        Spacer()
                    }
                }
                
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        inspectorVisible.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
            }
        }
        .font(.title)
        
    }
}
