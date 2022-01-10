#version 450 compatibility

uniform vec3 shadowLightPosition;

out vec4 color_vs;
out vec2 texture_coord_vs;

void main() {
    texture_coord_vs = gl_MultiTexCoord0.xy;

    // Transform position and normal
    gl_Position = ftransform();
    vec3 normal = (gl_NormalMatrix * gl_Normal).xyz;

    // Compute shaded color per triangle using normal
    vec4 biome_specific_color = gl_Color;
    float light_intensity = dot(normalize(shadowLightPosition), normal);

    color_vs = biome_specific_color;
    color_vs.rgb *= light_intensity;
}
