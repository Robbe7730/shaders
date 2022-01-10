#version 450 compatibility

out vec4 position_eye_vs;
out vec4 color_vs;
out vec3 normal_vs;
out vec2 texture_coord_vs;

void main() {
    // Transform position and normal (object to eye space)
    position_eye_vs = gl_ModelViewMatrix * gl_Vertex;
    normal_vs = gl_NormalMatrix * gl_Normal;

    // Transform position (eye to screen space)
    gl_Position = gl_ProjectionMatrix * position_eye_vs;

    // Pass through color
    color_vs = gl_Color;

    // (Used in fragment shading)
    texture_coord_vs = gl_MultiTexCoord0.xy;
}
