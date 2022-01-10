#version 450 compatibility

out vec4 color_vs;
out vec2 texture_coord_vs;

void main() {
    color_vs = gl_Color;
    texture_coord_vs = gl_MultiTexCoord0.st;

    gl_Position = ftransform();
}
