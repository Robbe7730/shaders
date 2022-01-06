#version 450 compatibility

#extension GL_ARB_geometry_shader4 : enable

#define TESSELATION_DEPTH 2

layout (triangles) in;
layout (triangle_strip, max_vertices = 68) out;

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
out vec3 shadowmap_coord_gs;
out vec4 color_gs;

vec3 screen_to_shadowmap_space(vec4 screen_coord) {
  vec4 shadowmap_coord = gbufferModelViewInverse * gbufferProjectionInverse * screen_coord;
  // You would think that at this point, shadowmap_coord should be
  // equal to world_coord but for some reason I don't understand, this
  // works and just using world_coord doesn't...
  shadowmap_coord = shadowProjection * shadowModelView * shadowmap_coord;
  shadowmap_coord /= shadowmap_coord.w;
  shadowmap_coord.xyz = shadowmap_coord.xyz * 0.5 + 0.5;
  return shadowmap_coord.xyz;
}

void emit_point(float s, float t) {
  vec3 base = gl_PositionIn[0].xyz;
  vec3 s_vec = (gl_PositionIn[1] - gl_PositionIn[0]).xyz;
  vec3 t_vec = (gl_PositionIn[2] - gl_PositionIn[0]).xyz;

  vec2 texture_base = texture_coord_vs[0];
  vec2 texture_s_vec = texture_coord_vs[1]-texture_coord_vs[0];
  vec2 texture_t_vec = texture_coord_vs[2]-texture_coord_vs[0];

  vec2 lightmap_base = lightmap_coord_vs[0];
  vec2 lightmap_s_vec = lightmap_coord_vs[1]-lightmap_coord_vs[0];
  vec2 lightmap_t_vec = lightmap_coord_vs[2]-lightmap_coord_vs[0];

  vec4 color_base = color_vs[0];
  vec4 color_s_vec = color_vs[1]-color_vs[0];
  vec4 color_t_vec = color_vs[2]-color_vs[0];

  gl_Position = vec4(base + s * s_vec + t * t_vec, 1.0);
  gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Position;
  texture_coord_gs = texture_base + s * texture_s_vec + t * texture_t_vec;
  lightmap_coord_gs = lightmap_base + s * lightmap_s_vec + t * lightmap_t_vec;
  shadowmap_coord_gs = screen_to_shadowmap_space(gl_Position);
  color_gs = color_base + s * color_s_vec + t * color_t_vec;
  EmitVertex();
}

void main() {
  int numLayers = 1 << TESSELATION_DEPTH;

  float delta = 1.0 / float(numLayers);
  float s = 0.0;
  for (int i = 0; i < numLayers; i++) {
    float t = 0.0;
    for (int j = 0; j < numLayers-i-1; j++) {
      emit_point(s, t);
      emit_point(s+delta, t);
      emit_point(s, t+delta);
      EndPrimitive();

      emit_point(s, t+delta);
      emit_point(s+delta, t);
      emit_point(s+delta, t+delta);
      EndPrimitive();

      t += delta;
    }
    emit_point(s, t);
    emit_point(s+delta, t);
    emit_point(s, t+delta);
    EndPrimitive();
    s += delta;
  }
}
