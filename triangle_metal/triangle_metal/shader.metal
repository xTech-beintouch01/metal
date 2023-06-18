//
//  shader.metal
//  triangle_metal
//
//  Created by Stella on 17.6.2023.
//


#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float3 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
};

vertex VertexOut vertexShader(const device Vertex* vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    // triangle vertices
    Vertex input = vertexArray[vid];
    VertexOut output;
    // assign the input pos to output, to pass from the shader down to subsequent stages of the rendering pipeline
    // float4 4d vector (x, y, z, w), set w = 1.0
    output.position = float4(input.position, 1.0);
    return output;
}

fragment float4 fragmentShader(VertexOut vertex_out [[stage_in]]) {
    return float4(1.0, 0.0, 0.0, 1.0); // Red color
}









