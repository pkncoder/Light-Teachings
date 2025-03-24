//
//  Renderer.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import MetalKit
import SwiftUI

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: RendererView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState
    
    init(_ parent: RendererView) {
        self.parent = parent
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        self.commandQueue = device.makeCommandQueue()
        
        pipeline = build_pipeline(device: device)
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor!)!
        
        renderEncoder.setRenderPipelineState(pipeline)
        
        // Inside the draw(in view:) method, before encoding commands:
        var screenSize = ScreenSize(
            width: Float(view.drawableSize.width),
            height: Float(view.drawableSize.height)
        )
        
        renderEncoder.setFragmentBytes(&screenSize, length: MemoryLayout<ScreenSize>.stride, index: 1)
        
        
        
        /* MARK: -SCENE-*/
        
        var objectArray: [Object] = [
            Object(
                origin: SIMD4<Float>(0, 0, 0, 0),
                bounds: SIMD4<Float>(10, 10, 10, 0),
                data: SIMD4<Float>(2, 1, 0, 0)
            ),
            Object(
                origin: SIMD4<Float>(0, 0, 0, 0),
                bounds: SIMD4<Float>(9, 9, 9, 3),
                data: SIMD4<Float>(3, 0, 0, 0)
            ),
            Object(
                origin: SIMD4<Float>(0, 0, 0, 0),
                bounds: SIMD4<Float>(1, 1, 1, 0.1),
                data: SIMD4<Float>(2, 0, 0, 0)
            )
        ]
        
        var lengths: SIMD4<Float> = SIMD4<Float>(Float(objectArray.count), 0, 0, 0)
        
        let objectBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<RayTracedScene>.stride)
        memcpy(objectBuffer?.contents(), &objectArray, MemoryLayout<RayTracedScene>.stride)
        memcpy(
            objectBuffer?.contents().advanced(by: MemoryLayout<Object>.stride * 10),
            &lengths,
            MemoryLayout<RayTracedScene>.stride
        )
        
        
        
        
        
        
        
        renderEncoder.setFragmentBuffer(objectBuffer, offset: 0, index: 2)
        
        
        
        
        
        
        
        
        
        
        
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 2, vertexCount: 3)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
