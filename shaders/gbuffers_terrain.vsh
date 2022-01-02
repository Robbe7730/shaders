#version 450 compatibility

out vec2 texture_coord_vs;
out vec2 lightmap_coord_vs;
out vec4 color_vs;

void main()
{
  gl_Position = gl_Vertex;

  texture_coord_vs = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lightmap_coord_vs = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  color_vs = gl_Color;
}
