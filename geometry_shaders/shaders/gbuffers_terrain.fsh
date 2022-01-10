#version 450 compatibility

const int shadowMapResolution = 2048; // Resolution of the shadow map. Higher values lead to nicer shadows, but require more computations. (see also: Shadow Quality in the main Shaders screen) [1024 2048 4096 8192]

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2DShadow shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor1;

// From Graphics Shader
in vec4 color_gs;
in vec2 texture_coord_gs;
in vec2 lightmap_coord_gs;
in vec3 shadowmap_coord_gs;

layout(location = 0) out vec4 color_fs;

void main() {
  float shadowmap_value_0 = shadow2D(shadowtex0, shadowmap_coord_gs).x;
  float shadowmap_value_1 = shadow2D(shadowtex1, shadowmap_coord_gs).x;

  vec2 block_sky_light = lightmap_coord_gs;

  vec4 light = texture2D(lightmap, block_sky_light);
  vec4 texture = texture2D(texture, texture_coord_gs);
  vec4 shadowcolor = texture2D(shadowcolor0, shadowmap_coord_gs.xy);

  color_fs = light * color_gs * texture;

  if (shadowmap_coord_gs.z - shadowmap_value_0 >= 0.0001 &&
      shadowmap_coord_gs.z - shadowmap_value_1 >= 0.0001) {
    color_fs.xyz *= 0.5;
  } else if (shadowmap_coord_gs.z - shadowmap_value_0 >= 0.0001 &&
      !(shadowmap_coord_gs.z - shadowmap_value_1 >= 0.0001)) {
    color_fs = vec4(mix(color_fs.xyz, shadowcolor.xyz, 0.5), color_fs.a);
  }
}
