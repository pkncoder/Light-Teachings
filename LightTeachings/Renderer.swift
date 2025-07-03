import MetalKit
import SwiftUI

class Renderer: NSObject, CAMetalDisplayLinkDelegate {
    
    
    // Rendering variables
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState

    private var sceneWrapper: SceneBuilder.SceneWrapper
    private var frameNum: Float
    
    private var sceneBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    
    // Uniform struct
    private var uniforms: Uniforms
    
    weak var metalLayer: CAMetalLayer?
    
    // Initializer
    init(rendererSettings: RendererSettings) {
        if let device = MTLCreateSystemDefaultDevice() { // Try to create the device, if sucesfull save it
            self.device = device
        } else {
            fatalError("Device could not be created")
        }
        self.commandQueue = device.makeCommandQueue() // Create the command que from the device
        self.pipeline = createPipeline(device: device) // Build the render pipeline and save it
        
        // Get the scene from the builder
        self.frameNum = 1
        
        self.sceneWrapper = rendererSettings.sceneWrapper
        
        self.uniforms = Uniforms()
        
        // Call the init function for MetalKit
        super.init()
        
        
        /* Create Buffers */
        self.sceneBuffer = self.buildSceneBuffer()!
       
        self.uniformBuffer = createUniformBuffer()!
        
        print("Renderer Init")
    }
    
    func attachToLayer(_ layer: CAMetalLayer) {
        self.metalLayer = layer
        layer.device = device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true

        // Set drawable size
        layer.drawableSize = CGSize(width: 300, height: 300)

        // Start the display link
        let displayLink = CAMetalDisplayLink(metalLayer: layer)
        displayLink.delegate = self
        displayLink.add(to: .main, forMode: .default)
    }
    
    func buildSceneBuffer() -> MTLBuffer? {
        
        // Split the portions of the scene
        var objectArray: [SceneBuilder.ObjectWrapper] = self.sceneWrapper.objects
        var materialArray: [SceneBuilder.MaterialWrapper] = self.sceneWrapper.materials
        var boundingBox: BoundingBox = BoundingBoxBuilder(objects: objectArray).fullBuild()
        var lengths: SIMD4<Float> = self.sceneWrapper.lengths
        
        // Create a buffer for the scene
        let sceneBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<RayTracedScene>.stride, options: [.storageModeShared])
        memcpy(sceneBuffer?.contents(), &objectArray, MemoryLayout<RayTracedScene>.stride) // Pass in the object array
        memcpy( // Pass in the lengths
            sceneBuffer?.contents().advanced(by: MemoryLayout<Object>.stride * 10), // Shift the memory so the off is past the object array
            &materialArray,
            MemoryLayout<RayTracedScene>.stride
        )
        memcpy(
            sceneBuffer?.contents().advanced(by: MemoryLayout<Object>.stride * 10 + MemoryLayout<ObjectMaterial>.stride * 10),
            &boundingBox,
            MemoryLayout<RayTracedScene>.stride
        )
        memcpy( // Pass in the lengths
            sceneBuffer?.contents().advanced(by: (MemoryLayout<Object>.stride * 10 + MemoryLayout<ObjectMaterial>.stride * 10 + MemoryLayout<BoundingBox>.stride)), // Shift the memory so the offset is past the object array
            &lengths,
            MemoryLayout<RayTracedScene>.stride
        )
        
        return sceneBuffer
    }
    
    func rebuildSceneBuffer(_ sceneWrapper: SceneBuilder.SceneWrapper) {
        
        self.sceneWrapper = sceneWrapper
        self.sceneBuffer = self.buildSceneBuffer()
    }
    
    func updateSceneBuffer(sceneWrapper: SceneBuilder.SceneWrapper, updateData: UpdateData) {
        
        self.sceneWrapper = sceneWrapper
        
        switch updateData.updateType {
            case .Object:
            
            sceneBuffer.contents().advanced(by: MemoryLayout<Object>.stride * updateData.updateIndex).copyMemory(from: &sceneWrapper.objects[updateData.updateIndex], byteCount: MemoryLayout<Object>.stride)
                var boundingBox: BoundingBox = BoundingBoxBuilder(objects: sceneWrapper.objects).fullBuild()
            sceneBuffer.contents().advanced(by: MemoryLayout<Object>.stride * 10 + MemoryLayout<ObjectMaterial>.stride * 10).copyMemory(from: &boundingBox, byteCount: MemoryLayout<BoundingBox>.stride)
            
            
            case .Material:
            
            sceneBuffer.contents().advanced(by: MemoryLayout<Object>.stride * 10 + MemoryLayout<ObjectMaterial>.stride * updateData.updateIndex).copyMemory(from: &sceneWrapper.materials[updateData.updateIndex], byteCount: MemoryLayout<ObjectMaterial>.stride)
            
            
            case .Light:
                break
        }
    }
    
    func createUniformBuffer() -> MTLBuffer? {
        
        // Create a buffer for the scene
        let uniformBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [.storageModeShared])
        
        return uniformBuffer
    }
    
    func metalDisplayLink(_ link: CAMetalDisplayLink, needsUpdate update: CAMetalDisplayLink.Update) {
//        print("Drew")
        draw(to: update.drawable)
        
    }
    
    // Main draw function - used
    func draw(to drawable: CAMetalDrawable) {
        
        /* MARK: - Info added Setup - */
        
        // Set the settings for the current render
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1.0) // What color the screen is cleared to
        renderPassDescriptor.colorAttachments[0].loadAction = .clear // What to do at the start of the render pass
        renderPassDescriptor.colorAttachments[0].storeAction = .store // What to do at the end of the render pass
        
        // Get a command *buffer* from the que to add commands too each frame
        let commandBuffer = commandQueue.makeCommandBuffer()!

        // Get the render encoder from the command buffer
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // Give the render encoder the pipeline
        renderEncoder.setRenderPipelineState(pipeline)
        
        
        /* MARK: -SCENE-*/
        
        // Set the buffer for the fragment function
        renderEncoder.setFragmentBuffer(self.sceneBuffer, offset: 0, index: 1);
                                        
                                        
        /* MARK: -UNIFORMS- */
        
        // Screen size
        let screenSize = ScreenSize(
            width: Float(drawable.layer.drawableSize.width),
            height: Float(drawable.layer.drawableSize.height)
        )
        
        var newUniforms = Uniforms(screenSize: screenSize, frameNum: frameNum, padding: 0)
        
        if (uniforms.screenSize.width != newUniforms.screenSize.width || uniforms.screenSize.height != newUniforms.screenSize.height) {
            uniformBuffer.contents().copyMemory(from: &newUniforms.screenSize, byteCount: MemoryLayout<ScreenSize>.stride)
            print("Updated Screen Size")
            
            uniforms.screenSize = newUniforms.screenSize
        }
        
        uniformBuffer.contents().advanced(by: MemoryLayout<ScreenSize>.stride).copyMemory(from: &newUniforms.frameNum, byteCount: MemoryLayout<Float>.stride)
                                                                                          
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
        
        // Wait for the GPU to stop the screen tearing
        commandBuffer.waitUntilCompleted()
        
        // Increase the frame number
        frameNum += 1
    }
}
