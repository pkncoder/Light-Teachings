//
//  PipelineBuilder.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

import Metal

func build_pipeline(device: MTLDevice) -> MTLRenderPipelineState {
    let pipeline: MTLRenderPipelineState // Create a pipeline
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor() // Get a descriptor for it
    let library = device.makeDefaultLibrary()! // Save a a library
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexMain") // Add a vertex shader with the name
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentMain") // Add a fragment shader
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // Set the pixel format
    
    // Try to make and return the pipeline with the descripter
    do {
        try pipeline = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline
    } catch { // If failed print and fatal error
        print("failed")
        fatalError()
    }
}
