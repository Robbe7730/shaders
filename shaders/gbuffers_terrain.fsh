#version 450 compatibility

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2DShadow shadow;

// From Graphics Shader
in vec4 color_gs;
in vec2 texture_coord_gs;
in vec2 lightmap_coord_gs;
in vec3 shadowmap_coord_gs;

layout(location = 0) out vec4 color_fs;

void main() {
  vec4 shadowmap_depth = shadow2D(shadow, shadowmap_coord_gs.xyz);
  vec2 block_sky_light = lightmap_coord_gs;

  if (shadowmap_coord_gs.z - shadowmap_depth.x >= 0.0001) {
    // Set the skylight to zero;
    block_sky_light.y = 0.0;
  }

  vec4 light = texture2D(lightmap, block_sky_light);
  vec4 texture = texture2D(texture, texture_coord_gs);

  color_fs = light * color_gs * texture;
  color_fs = color_gs;
}
