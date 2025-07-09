import Metal

func createPipeline(device: MTLDevice) -> MTLRenderPipelineState {
    
    // Final pipeline variable
    let pipeline: MTLRenderPipelineState
    
    // Create the descriptor and library that is used for settings and metal functions
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    let library = device.makeDefaultLibrary()!
    
    // Link or 'create' the vert and frag functins
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexMain") // Add a vertex shader with the name
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentMain") // Add a fragment shader
    
    // Set the pixel color format
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // Try to make the pipeline
    do {
        try pipeline = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline // If success, return the pipeline
    } catch {
        // If failed send a fatal error to stop the code
        fatalError("Pipeline Creation Failed")
    }
}
