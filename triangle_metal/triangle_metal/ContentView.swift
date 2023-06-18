//
//  ContentView.swift
//  metal_triangle
//
//  Created by Stella on 17.6.2023.
//

import SwiftUI
import MetalKit

// create a project: ios app
// frameworks

// flow vs openGL flow:
// shader.metal -> process vertex and fragment shader
// create triangle coord vertices/vertex buffer
// device -> render the pipeline -> bind the pipeline -> commit command queue buffer encoder
// swiftui -> wrap the metal view

struct MetalTriangleView: UIViewRepresentable {
    
    static var defaultLibrary: MTLLibrary = {
        guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else {
            fatalError("Failed to create default Metal library")
        }
        return library
    }()
    
    // Set up rendering pipeline
    static var pipelineState: MTLRenderPipelineState = {
        // descriptor: for the configuration, specification in various stages of the pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
        // bgra8Unorm: blue, green, red and alpha, 8 bits per component(32 bits per pixel)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let pipelineState = try? MTLCreateSystemDefaultDevice()?.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Failed to create render pipeline state")
        }
        
        return pipelineState
    }()
    
    // delegate: set the rendering process handler methods
    // to separate the rendering logic from the view itself
    class Coordinator: NSObject, MTKViewDelegate {
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle view size change if needed
        }
        
        func draw(in view: MTKView) {
            
            // Set up vertex data
            let vertices: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.5, 0),
                SIMD3<Float>(-0.5, -0.5, 0),
                SIMD3<Float>(0.5, -0.5, 0)
            ]
            let vertexBuffer = view.device?.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: [])
            
            
            // guard: var not assigned to nil val, otherwise early exit
            guard let commandBuffer = view.device?.makeCommandQueue()?.makeCommandBuffer(),
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            // bind the pipeline -> vertex buffer -> draw -> commit command queue buffer
            renderEncoder.setRenderPipelineState(MetalTriangleView.pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
            renderEncoder.endEncoding()
            
            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
            
            commandBuffer.commit()
        }
    }
    
    // initialize an instance/obj from the class
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.delegate = context.coordinator
        
        // under metal view scope
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = MetalTriangleView.defaultLibrary.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = MetalTriangleView.defaultLibrary.makeFunction(name: "fragmentShader")
        
        do {
            //?: to donate optional types that may or may not exist, 'device' value or 'nil'
            try metalView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create render pipeline state: \(error)")
        }
        
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update Metal view if needed
    }
    
}

// initializing main...
struct ContentView: View {
    var body: some View {
        MetalTriangleView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

