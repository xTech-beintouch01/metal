//
//  ContentView.swift
//  metal_triangle
//
//  Created by Stella on 17.6.2023.
//

import SwiftUI
import MetalKit

struct MetalTriangleView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.delegate = context.coordinator
        
        // Set up Metal rendering pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = MetalTriangleView.defaultLibrary.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = MetalTriangleView.defaultLibrary.makeFunction(name: "fragmentShader")
        
        do {
            try metalView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create render pipeline state: \(error)")
        }
        
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update Metal view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle view size change if needed
        }
        
        func draw(in view: MTKView) {
            guard let commandBuffer = view.device?.makeCommandQueue()?.makeCommandBuffer(),
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            // Set up vertex data
            let vertices: [SIMD3<Float>] = [
                SIMD3<Float>(0, 0.5, 0),
                SIMD3<Float>(-0.5, -0.5, 0),
                SIMD3<Float>(0.5, -0.5, 0)
            ]
            let vertexBuffer = view.device?.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: [])
            
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
    
    static var defaultLibrary: MTLLibrary = {
        guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else {
            fatalError("Failed to create default Metal library")
        }
        return library
    }()
    
    static var pipelineState: MTLRenderPipelineState = {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let pipelineState = try? MTLCreateSystemDefaultDevice()?.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Failed to create render pipeline state")
        }
        
        return pipelineState
    }()
}

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

