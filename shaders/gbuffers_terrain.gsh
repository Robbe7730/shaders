#version 450 compatibility

#extension GL_ARB_geometry_shader4 : enable

#define TESSELATION_DEPTH 0
#define TESSELATION_NUM_VERTICES (int(pow(2, 2 * TESSELATION_DEPTH + 1) + pow(2, TESSELATION_DEPTH + 2) + pow(2, TESSELATION_DEPTH + 1) + 2))
#define TESSELATION_NUM_TRIANGLES (int(pow(4, TESSELATION_DEPTH)))

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
out vec3 shadowmap_coord_gs;
out vec4 color_gs;

struct Point {
  vec4 screen_coord;
  vec2 texture_coord;
  vec2 lightmap_coord;
  vec3 shadowmap_coord;
  vec4 color;
};

Point get_initial_point(int i) {
  vec4 world_coord = gl_PositionIn[i];
  vec4 screen_coord = gl_ProjectionMatrix * gl_ModelViewMatrix * world_coord;

  vec4 shadowmap_coord = gbufferModelViewInverse * gbufferProjectionInverse * screen_coord;
  // You would think that at this point, shadowmap_coord_gs should be
  // equal to world_coord but for some reason I don't understand, this
  // works and just using world_coord doesn't...
  shadowmap_coord = shadowProjection * shadowModelView * shadowmap_coord;
  shadowmap_coord /= shadowmap_coord.w;
  shadowmap_coord.xyz = shadowmap_coord.xyz * 0.5 + 0.5;

  return Point(
    screen_coord,
    texture_coord_vs[i],
    lightmap_coord_vs[i],
    shadowmap_coord.xyz,
    color_vs[i]
  );
}

void main()
{
  int num_triangles = 1;

  Point[TESSELATION_NUM_VERTICES] points;

  ivec3 triangles[TESSELATION_NUM_TRIANGLES];

  int vertex_i = 0;

  // Initial triangle
  for (vertex_i = 0; vertex_i < 3; vertex_i++) {
    points[vertex_i] = get_initial_point(vertex_i);
  }

  triangles[0] = ivec3(0, 1, 2);

  // Emit the triangles
  for (int triangle_id = 0; triangle_id < triangles.length(); triangle_id++) {
    ivec3 triangle = triangles[triangle_id];
    for (int vertex_id = 0; vertex_id < 3; vertex_id++) {
      Point p = points[vertex_id];
      gl_Position = p.screen_coord;
      texture_coord_gs = p.texture_coord;
      shadowmap_coord_gs = p.shadowmap_coord;
      lightmap_coord_gs = p.lightmap_coord;
      color_gs = p.color;
      EmitVertex();
    }
    EndPrimitive();
  }
}
