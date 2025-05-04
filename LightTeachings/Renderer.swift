import MetalKit
import SwiftUI

class Renderer: NSObject, MTKViewDelegate {
    
    // Rendering variables
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState

    var sceneWrapper: SceneBuilder.SceneWrapper
    private var frameNum: Float
    
    private var sceneBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    
    // Initializer
    override init() {
        if let device = MTLCreateSystemDefaultDevice() { // Try to create the device, if sucesfull save it
            self.device = device
        } else {
            fatalError("Device could not be created")
        }
        self.commandQueue = device.makeCommandQueue() // Create the command que from the device
        self.pipeline = createPipeline(device: device) // Build the render pipeline and save it
        
//         Make the scene builder and pass in the file name
        let sceneBuilder: SceneBuilder = SceneBuilder("lifeScene")
        
        // Get the scene from the builder
        self.sceneWrapper = sceneBuilder.getScene()
        self.frameNum = 1
        
        // Call the init function for MetalKit
        super.init()
        
        
        /* Create Buffers */
        self.sceneBuffer = buildSceneBuffer()!
        self.uniformBuffer = createUniformBuffer()!
    }
    
    func buildSceneBuffer() -> MTLBuffer? {
        
        // Split the portions of the scene
        var objectArray: [SceneBuilder.ObjectWrapper] = sceneWrapper.objects
        var materialArray: [SceneBuilder.MaterialWrapper] = sceneWrapper.materials
        var lengths: SIMD4<Float> = sceneWrapper.lengths
        
        // Create a buffer for the scene
        let sceneBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<RayTracedScene>.stride, options: [.storageModeShared])
        memcpy(sceneBuffer?.contents(), &objectArray, MemoryLayout<RayTracedScene>.stride) // Pass in the object array
        memcpy( // Pass in the lengths
            sceneBuffer?.contents().advanced(by: MemoryLayout<Object>.stride * 10), // Shift the memory so the off is past the object array
            &materialArray,
            MemoryLayout<RayTracedScene>.stride
        )
        memcpy( // Pass in the lengths
            sceneBuffer?.contents().advanced(by: (MemoryLayout<Object>.stride * 10 + MemoryLayout<RayTracingMaterial>.stride * 10)), // Shift the memory so the offset is past the object array
            &lengths,
            MemoryLayout<RayTracedScene>.stride
        )
        
        return sceneBuffer
    }
    
    func rebuildSceneBuffer() {
        self.sceneBuffer = buildSceneBuffer()
    }
    
    func createUniformBuffer() -> MTLBuffer? {
        
        // Create a buffer for the scene
        let uniformBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [.storageModeShared])
        
        return uniformBuffer
    }
    
    // View initializer - not used
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    // Main draw function - used
    func draw(in view: MTKView) {
        
        
        /* MARK: - Info added Setup - */
        
        // Get the drawable from the view - protections are put so bad errors don't happen
        guard let drawable = view.currentDrawable else {
            return
        }
        
        view.drawableSize = CGSize(width: 300, height: 300)
        
        // Set the settings for the current render
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1.0) // What color the screen is cleared to
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear // What to do at the start of the render pass
        renderPassDescriptor?.colorAttachments[0].storeAction = .store // What to do at the end of the render pass
        
        // Get a command *buffer* from the que to add commands too each frame
        let commandBuffer = commandQueue.makeCommandBuffer()!

        // Get the render encoder from the command buffer
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor!)!
        
        // Give the render encoder the pipeline
        renderEncoder.setRenderPipelineState(pipeline)
        
        
        /* MARK: -SCENE-*/
        
        // Set the buffer for the fragment function
        renderEncoder.setFragmentBuffer(self.sceneBuffer, offset: 0, index: 1);
                                        
                                        
        /* MARK: -UNIFORMS- */
        
        // Screen size
        let screenSize = ScreenSize(
            width: Float(view.drawableSize.width),
            height: Float(view.drawableSize.height)
        )
        
        // Uniform struct
        var uniforms = Uniforms(
            screenSize: screenSize,
            frameNum: frameNum,
            padding: 0
        );
        
        // Update the frame number
        memcpy(self.uniformBuffer?.contents(), &uniforms, MemoryLayout<Uniforms>.stride)
        
        // Pass it to the fragment
        renderEncoder.setFragmentBuffer(self.uniformBuffer, offset: 0, index: 2)
        
        /* MARK: - Post info added setup - */
        
        // Draw two trainlges covering the window
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        // Finish the encoding
        renderEncoder.endEncoding()
        
        // Present the drawable
        commandBuffer.present(drawable)
        
        // Commit the changes to the command buffer
        commandBuffer.commit()
        
//        // Wait for the GPU to stop the screen tearing
//        commandBuffer.waitUntilCompleted()
        
        // Increase the frame number
        frameNum += 1
    }
}
