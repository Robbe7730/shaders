#version 450 compatibility

// Outputs
out vec3 normal_vs;
out vec4 biome_specific_color_vs;
out vec2 texture_coord_vs;
out vec4 screen_coord_vs;
out vec2 light_levels_vs;

void main() {
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;

    normal_vs = (gl_NormalMatrix * gl_Normal).xyz;

    biome_specific_color_vs = gl_Color;

    texture_coord_vs = gl_MultiTexCoord0.st;

    screen_coord_vs = gl_Position;

    light_levels_vs = gl_MultiTexCoord1.st;
}
