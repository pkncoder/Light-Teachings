import SwiftUI
import MetalKit

class MetalViewLayer: NSView {
    
    // Create the layer for the NSView
    override func makeBackingLayer() -> CALayer {
        let metalLayer = CAMetalLayer()
        metalLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        return metalLayer
    }

    // Saved layer (as a CAMetalLayer)
    public var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }
}
