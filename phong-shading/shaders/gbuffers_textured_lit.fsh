#version 450 compatibility

uniform sampler2D texture;
uniform vec3 shadowLightPosition;

// (Interpolation happens automatically)
in vec4 position_eye_vs;
in vec4 color_vs;
in vec3 normal_vs;
in vec2 texture_coord_vs;

layout(location = 0) out vec4 color_fs;

void main() {
  // (Apply texture to get actual color)
  vec4 texture_color = texture2D(texture, texture_coord_vs);
  vec4 color = color_vs * texture_color;

  // Compute shading using interpolated color and normal

  //   Calculate ambient and diffuse shading
  float light_intensity = dot(normalize(shadowLightPosition), normal_vs);
  color_fs = color;
  color_fs.rgb *= light_intensity;

  //   Calculate highlights
  vec3 e = normalize(-position_eye_vs.xyz);
  vec3 l = normalize(shadowLightPosition);
  vec3 h = (e + l) / length(e + l);
  color_fs.rgb += vec3(1.0) * pow(dot(h, normal_vs), 1000);

  // (Z-culling happens automatically)
}
