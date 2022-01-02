#version 450 compatibility

#extension GL_ARB_geometry_shader4 : enable

const int maxVerticesOut = 12;

// From Optifine/Minecraft

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

// From Vertex Shader

in vec2 texture_coord_vs[];
in vec2 lightmap_coord_vs[];
in vec4 color_vs[];

// Output

out vec2 texture_coord_gs;
out vec2 lightmap_coord_gs;
out vec4 shadowmap_coord_gs;
out vec4 color_gs;

void emit_point(vec4 world_pos, vec2 texture_pos, vec2 lightmap_pos, vec4 color) {
  gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * world_pos;

  shadowmap_coord_gs = gbufferModelViewInverse * gbufferProjectionInverse * gl_Position;
  // You would think that at this point, shadowmap_coord_gs should be equal to world_pos
  // but for some reason I don't understand, this works and just using world_pos doesn't
  shadowmap_coord_gs = shadowProjection * shadowModelView * shadowmap_coord_gs;
  shadowmap_coord_gs /= shadowmap_coord_gs.w;
  shadowmap_coord_gs.xyz = shadowmap_coord_gs.xyz * 0.5 + 0.5;

  texture_coord_gs = texture_pos;
  lightmap_coord_gs = lightmap_pos;
  color_gs = color;

  EmitVertex();
}

void emit_existing(int i) {
  emit_point(
    gl_PositionIn[i],
    texture_coord_vs[i],
    lightmap_coord_vs[i],
    color_vs[i]
  );
}

void emit_between(int i, int j) {
  emit_point(
    (gl_PositionIn[i] + gl_PositionIn[j]) / 2.0,
    (texture_coord_vs[i] + texture_coord_vs[j]) / 2.0,
    (lightmap_coord_vs[i] + lightmap_coord_vs[j]) / 2.0,
    (color_vs[i] + color_vs[j]) / 2.0
  );
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
