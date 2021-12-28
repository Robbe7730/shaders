#version 450 compatibility

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D shadow;
uniform mat4 shadowModelView;
uniform sampler2D lightmap;

// From Vertex Shader
in vec3 normal_vs;
in vec4 biome_specific_color_vs;
in vec2 texture_coord_vs;
in vec2 screen_coord_vs;
in vec2 light_levels_vs;

// Outputs
layout(location = 0) out vec4 color_fs;
layout(location = 2) out vec3 normal_fs;

void main() {
    normal_fs = normal_vs;

    const vec4 texture_color = texture2D(texture, texture_coord_vs);
    const vec4 color = texture_color * biome_specific_color_vs;
    color_fs = texture2D(lightmap, light_levels_vs / 255) * color;
}
