#version 450 compatibility

layout(location = 6) out float depth;

void main() {
    depth = gl_FragCoord.z / gl_FragCoord.w;
}
