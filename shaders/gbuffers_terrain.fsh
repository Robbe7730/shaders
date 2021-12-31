#version 450 compatibility

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D lightmap;

// From Graphics Shader
in vec4 color_gs;
in vec2 texture_coord_gs;
in vec2 lightmap_coord_gs;

layout(location = 0) out vec4 color_fs;

void main() {
  vec4 light = texture2D(lightmap, lightmap_coord_gs);
  vec4 texture = texture2D(texture, texture_coord_gs);

  color_fs = color_gs * texture * light;
}
