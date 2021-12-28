#version 450 compatibility

#define M_PI 3.1415926535897932384626433832795

// From Optifine/Minecraft
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

// Outputs
out vec2 texcoord_vs;
out vec4 biome_specific_color_vs;
out vec2 light_levels_vs;
out vec3 normal_vs;
out vec3 direction_vs;

void main() {
    texcoord_vs = gl_MultiTexCoord0.st;

    biome_specific_color_vs = gl_Color;

    light_levels_vs = gl_MultiTexCoord1.st;

    gl_Position = ftransform();
    direction_vs = normalize((gbufferModelViewInverse * gbufferProjectionInverse * gl_Position).xyz);

    normal_vs = gl_Normal.xyz;
}

