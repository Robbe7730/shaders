#version 450 compatibility

// From Optifine/Minecraft
uniform sampler2D texture;

// From Vertex Shader
in vec4 color_vs;
in vec2 texture_coord_vs;

// Outputs
layout(location = 0) out vec4 color_fs;

void main() {
    // sky color has no biome specific color
    color_fs = color_vs;
}
