import MetalKit
import SwiftUI

class Renderer: NSObject, CAMetalDisplayLinkDelegate {
    
    // Rendering variables
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState

    // Scene wrapper that's being rendered
    private var sceneWrapper: SceneBuilder.SceneWrapper
    
    // Buffers
    private var sceneBuffer: MTLBuffer!
    private var backSceneBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    
    // Uniform struct and info
    private var uniforms: Uniforms
    private var frameNum: Float
    
    // Drawing layer
    weak var metalLayer: CAMetalLayer?
    
    private let objectMemSize = MemoryLayout<Object>.stride
    private let objectMatMemSize = MemoryLayout<ObjectMaterial>.stride
    private let boundingBoxMemSize = MemoryLayout<BoundingBox>.stride
    private let lengthsMemSize = MemoryLayout<SIMD4<Float>>.stride
    private let sceneMemSize = MemoryLayout<RayTracedScene>.stride
    
    // Initializer
    init(rendererSettings: RendererSettings) {
        
        // Get metal device
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        } else {
            fatalError("Device could not be created")
        }
        
        // Drawing necesities
        self.commandQueue = device.makeCommandQueue() // Create the command que from the device
        self.pipeline = createPipeline(device: device) // Build the render pipeline and save it
        
        
        // Get the scene wrapper
        self.sceneWrapper = rendererSettings.sceneWrapper
        
        // Create uniforms
        self.uniforms = Uniforms()
        self.frameNum = 1
        
        // Call the init function for MetalKit
        super.init()
        
        /* Create Buffers */
        self.sceneBuffer = self.buildSceneBuffer()!
        self.backSceneBuffer = self.sceneBuffer
        
        self.uniformBuffer = createUniformBuffer()!
    }
    
    // Setup metal layer for drawwing and create the display link
    func attachToLayer(_ layer: CAMetalLayer) {
        
        // Save layer
        self.metalLayer = layer
        
        // Set attributes
        layer.device = device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true

        // Set drawable size (scaled on presentation
        layer.drawableSize = CGSize(width: 300, height: 300)

        // Start the display link
        let displayLink = CAMetalDisplayLink(metalLayer: layer)
        displayLink.delegate = self
        displayLink.add(to: .main, forMode: .common)
    }
    
    // Builds a full scene buffer (uses self.sceneWrapper)
    func buildSceneBuffer() -> MTLBuffer? {
        
        // Split the portions of the scene
        var objectArray: [SceneBuilder.ObjectWrapper] = self.sceneWrapper.objects
        var materialArray: [SceneBuilder.MaterialWrapper] = self.sceneWrapper.materials
        var boundingBox: BoundingBox = BoundingBoxBuilder(objects: objectArray).fullBuild() // Build the bounding box
        var lengths: SIMD4<Float> = self.sceneWrapper.lengths
        
        // Create a buffer for the scene
        let sceneBuffer: MTLBuffer? = device.makeBuffer(length: sceneMemSize, options: [.storageModeShared])
        
        sceneBuffer?.contents().copyMemory(from: &objectArray, byteCount: objectMemSize * 10) // Pass in the object array
        
        // Pass in the lengths
        sceneBuffer?.contents().advanced(by: objectMemSize * 10).copyMemory( // Shift the memory so the off is past the object array
            from: &materialArray,
            byteCount: objectMatMemSize * 10
        )
        
        // Pass in the bounding box
        sceneBuffer?.contents().advanced(by: objectMemSize * 10 + objectMatMemSize * 10).copyMemory(
            from: &boundingBox,
            byteCount: boundingBoxMemSize
        )
        
        // Pass in the lengths
        sceneBuffer?.contents().advanced(by: (objectMemSize * 10 + objectMatMemSize * 10 + boundingBoxMemSize)).copyMemory( // Shift the memory so the offset is past the object array
            from: &lengths,
            byteCount: lengthsMemSize
        )
        
        return sceneBuffer
    }
    
    // Full rebuild of the scene buffer with new scene wrapper
    func rebuildSceneBuffer(_ sceneWrapper: SceneBuilder.SceneWrapper) {
        
        // Save new scene wrapper then build
        self.sceneWrapper = sceneWrapper
        self.sceneBuffer = self.buildSceneBuffer()
    }
    
    // Update the scene wrapper in one spot
    func updateSceneBuffer(sceneWrapper: SceneBuilder.SceneWrapper, updateData: UpdateData) {
        
        // Save new scene wrapper
        self.sceneWrapper = sceneWrapper
        
        // Create a back scene buffer
//        var backSceneBuffer: MTLBuffer!
        backSceneBuffer = self.sceneBuffer
        
        // Switch through the update types
        switch updateData.updateType {
            
            // Object (with bounding box)
            case .Object:
                
                // Advance through to the next index and set new object info
                backSceneBuffer.contents().advanced(by: objectMemSize * updateData.updateIndex).copyMemory(from: &sceneWrapper.objects[updateData.updateIndex], byteCount: objectMemSize)
            
                // Get the new bounding box and set it too
                var boundingBox: BoundingBox = BoundingBoxBuilder(objects: sceneWrapper.objects).fullBuild()
                backSceneBuffer.contents().advanced(by: objectMemSize * 10 + objectMatMemSize * 10).copyMemory(from: &boundingBox, byteCount: boundingBoxMemSize)
            
            // Material
            case .Material:
                
            // Set the new material at the correct index
                backSceneBuffer.contents().advanced(by: objectMemSize * 10 + objectMatMemSize * updateData.updateIndex).copyMemory(from: &sceneWrapper.materials[updateData.updateIndex], byteCount: objectMatMemSize)
                
            // Full rebuild
            case .Full:
                backSceneBuffer = self.buildSceneBuffer()
            
            // TODO: NOT IMPLIMENTED
            case .Light:
                break
            
        }
        
        // Update to the new scene buffer
        
    }
    
    // Create the uniform buffer
    func createUniformBuffer() -> MTLBuffer? {
        
        // Create a buffer for the scene
        let uniformBuffer: MTLBuffer? = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [.storageModeShared])
        return uniformBuffer
    }
    
    // Update function from the metal display link
    func metalDisplayLink(_ link: CAMetalDisplayLink, needsUpdate update: CAMetalDisplayLink.Update) {
        draw(to: update.drawable) // Call draw function and pass through the new drawable
        
    }
    
    // Main draw function called from metalDisplayLink()
    func draw(to drawable: CAMetalDrawable) {
        
        /* MARK: - Settup info - */
        
        // Set the settings for the current render
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1.0) // What color the screen is cleared to
        renderPassDescriptor.colorAttachments[0].loadAction = .clear // What to do at the start of the render pass
        renderPassDescriptor.colorAttachments[0].storeAction = .store // What to do at the end of the render pass
        
        // Get a command *buffer*
        let commandBuffer = commandQueue.makeCommandBuffer()!

        // Get the render encoder from the command buffer
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // Give the render encoder the pipeline
        renderEncoder.setRenderPipelineState(pipeline)
        
        
        
        /* MARK: -SCENE- */
        
        // Update to the back scene buffer
        self.sceneBuffer.contents().copyMemory(from: backSceneBuffer.contents(), byteCount: self.sceneBuffer.length)
        
        // Give the fragment buffer the scene info
        renderEncoder.setFragmentBuffer(self.sceneBuffer, offset: 0, index: 1);
                                        
                        
        
        /* MARK: -UNIFORMS- */
        
        // Screen size
        let screenSize = ScreenSize(
            width: Float(drawable.layer.drawableSize.width),
            height: Float(drawable.layer.drawableSize.height)
        )
        
        // Create a new uniform struct
        var newUniforms = Uniforms(screenSize: screenSize, frameNum: frameNum, padding: 0)
        
        // Check for updates
        if (uniforms.screenSize.width != newUniforms.screenSize.width || uniforms.screenSize.height != newUniforms.screenSize.height) {
            
            // If needed to, copy in the new screen size
            uniformBuffer.contents().copyMemory(from: &newUniforms.screenSize, byteCount: MemoryLayout<ScreenSize>.stride)
            uniforms.screenSize = newUniforms.screenSize
        }
        
        // Update the uniform buffer for the frame num
        uniformBuffer.contents().advanced(by: MemoryLayout<ScreenSize>.stride).copyMemory(from: &newUniforms.frameNum, byteCount: MemoryLayout<Float>.stride)
                                                                                          
        // Pass it to the fragment shader
        renderEncoder.setFragmentBuffer(self.uniformBuffer, offset: 0, index: 2)
        
        
        
        /* MARK: - Draw call(s) - */
        
        // Draw two trainlges covering the window
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        
        
        /* MARK: - Post-draw and presentation - */
        
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
