//
//  Coordinater.swift
//  SimpleRayTracer
//
//  Created by Kia Preston on 3/17/25.
//

import SwiftUI

class Coordinator: NSObject {
    var parent: RendererView
    var renderer: Renderer

    init(parent: RendererView) {
        self.parent = parent
        self.renderer = Renderer(parent)
    }
}
