#version 450 compatibility

#define M_PI 3.1415926535897932384626433832795

// From Optifine/Minecraft
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

// Outputs
out vec2 texcoord_vs;
out vec4 biome_specific_color_vs;
out vec2 light_levels_vs;
out vec3 normal_vs;
out vec3 direction_vs;
out vec3 world_position_vs;
out vec3 position_vs;

#include "bump.glsl"
#include "tangent.glsl"

void main() {
    texcoord_vs = gl_MultiTexCoord0.st;

    biome_specific_color_vs = gl_Color;

    light_levels_vs = gl_MultiTexCoord1.st;

    gl_Position = ftransform();

    position_vs = cameraPosition + (gbufferModelViewInverse * gbufferProjectionInverse * gl_Position).xyz;

    direction_vs = normalize((gbufferModelViewInverse * gbufferProjectionInverse * gl_Position).xyz);

    vec3 T;
    vec3 B;
    tangent(gl_Normal.xyz, T, B);
    float epsilon = 0.0001;
    normal_vs = cross(
      (
        bump_position(frameTimeCounter, position_vs + epsilon*T) -
        bump_position(frameTimeCounter, position_vs)
      ) / epsilon,
      (
        bump_position(frameTimeCounter, position_vs + epsilon*B) -
        bump_position(frameTimeCounter, position_vs)
      ) / epsilon
    );
    position_vs = bump_position(frameTimeCounter, position_vs);
}

