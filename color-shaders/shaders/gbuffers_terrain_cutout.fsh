#version 450 compatibility

layout(location = 0) out vec4 color_fs;

void main() {
  color_fs = vec4(0.0, 0.0, 255.0, 255.0) / 255.0;
}
