#version 450 compatibility

uniform sampler2D texture;

in vec4 color_vs;
in vec2 texture_coord_vs;

layout(location = 0) out vec4 color_fs;

void main() {
  // Apply texture
  vec4 texture_color = texture2D(texture, texture_coord_vs);
  color_fs = color_vs * texture_color;
}
