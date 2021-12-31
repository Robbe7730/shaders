#version 450 compatibility

#extension GL_ARB_geometry_shader4 : enable

const int maxVerticesOut = 12;

in vec2 texture_coord_vs[];
in vec2 lightmap_coord_vs[];
in vec4 color_vs[];

out vec2 texture_coord_gs;
out vec2 lightmap_coord_gs;
out vec4 color_gs;

void emit_existing(int i) {
  gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_PositionIn[i];
  texture_coord_gs = texture_coord_vs[i];
  lightmap_coord_gs = lightmap_coord_vs[i];
  color_gs = color_vs[i];
  EmitVertex();
}

void emit_between(int i, int j) {
  gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * ((gl_PositionIn[i] + gl_PositionIn[j]) / 2.0);
  texture_coord_gs = (texture_coord_vs[i] + texture_coord_vs[j]) / 2.0;
  lightmap_coord_gs = (lightmap_coord_vs[i] + lightmap_coord_vs[j]) / 2.0;

  // These should be the same every time?
  color_gs = (color_vs[i] + color_vs[j]) / 2.0;
  EmitVertex();
}

void main()
{
  emit_existing(0);
  emit_between(0, 1);
  emit_between(0, 2);
  EndPrimitive();

  emit_existing(1);
  emit_between(1, 2);
  emit_between(1, 0);
  EndPrimitive();

  emit_existing(2);
  emit_between(2, 0);
  emit_between(2, 1);
  EndPrimitive();

  emit_between(0, 1);
  emit_between(1, 2);
  emit_between(2, 0);
  EndPrimitive();
}
