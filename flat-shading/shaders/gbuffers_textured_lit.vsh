#version 450 compatibility

uniform vec3 shadowLightPosition;

out vec4 color_vs;
out vec2 texture_coord_vs;

void main() {
    // Transform position and normal (object to eye space)
    vec4 position_eye_space = gl_ModelViewMatrix * gl_Vertex;
    vec3 normal = (gl_NormalMatrix * gl_Normal).xyz;

    // Compute shaded color per triangle using normal
    vec4 biome_specific_color = gl_Color;
    float light_intensity = dot(normalize(shadowLightPosition), normal);
    color_vs = biome_specific_color;
    color_vs.rgb *= light_intensity;

    // Transform position (eye to screen space)
    gl_Position = gl_ProjectionMatrix * position_eye_space;

    // (Used in fragment shading)
    texture_coord_vs = gl_MultiTexCoord0.xy;
}
