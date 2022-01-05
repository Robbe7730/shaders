#version 450 compatibility

#extension GL_ARB_geometry_shader4 : enable

#define TESSELATION_DEPTH 2
#define TESSELATION_NUM_VERTICES (int(pow(2, 2 * TESSELATION_DEPTH - 1) + pow(2, TESSELATION_DEPTH) + pow(2, TESSELATION_DEPTH - 1) + 1))
#define TESSELATION_NUM_TRIANGLES (int(pow(4, TESSELATION_DEPTH)))

layout (triangles) in;
layout (triangle_strip, max_vertices = 128) out;

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
  vec4 world_coord;
  vec4 screen_coord;
  vec2 texture_coord;
  vec2 lightmap_coord;
  vec3 shadowmap_coord;
  vec4 color;
};

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

Point get_initial_point(int i) {
  vec4 world_coord = gl_PositionIn[i];
  vec4 screen_coord = gl_ProjectionMatrix * gl_ModelViewMatrix * world_coord;

  return Point(
    world_coord,
    screen_coord,
    texture_coord_vs[i],
    lightmap_coord_vs[i],
    screen_to_shadowmap_space(screen_coord),
    color_vs[i]
  );
}

Point interpolate(Point a, Point b) {
  vec4 world_coord = (a.world_coord + b.world_coord) / 2.0;
  vec4 screen_coord = gl_ProjectionMatrix * gl_ModelViewMatrix * world_coord;
  vec2 texture_coord = (a.texture_coord + b.texture_coord) / 2.0;
  vec2 lightmap_coord = (a.lightmap_coord + b.lightmap_coord) / 2.0;
  vec4 color = (a.color + b.color) / 2.0;

  return Point(
    world_coord,
    screen_coord,
    texture_coord,
    lightmap_coord,
    screen_to_shadowmap_space(screen_coord),
    color
  );
}

void main() {
  Point[TESSELATION_NUM_VERTICES] points;

  ivec3 triangles[TESSELATION_NUM_TRIANGLES];

  int point_i = 0;
  int triangle_i = 0;

  // Initial triangle
  for (point_i = 0; point_i < 3; point_i++) {
    points[point_i] = get_initial_point(point_i);
  }

  triangles[triangle_i] = ivec3(0, 1, 2);

  // Split up
  // WHY DO YOU EXECUTE THE FOR LOOP IF THE CONDITION IS NOT SATISFIED
  // IN THE FIRST ITERATION?
  if (TESSELATION_DEPTH != 0) {
    for (int iteration = 0; iteration < TESSELATION_DEPTH; iteration++) {
      triangle_i = 0;
      ivec3 old_triangles[TESSELATION_NUM_TRIANGLES] = triangles;
      for (int triangle_id = 0; triangle_id < pow(4, iteration); triangle_id++) {
        ivec3 triangle = old_triangles[triangle_id];

        Point point1 = points[triangle.x];
        Point point2 = points[triangle.y];
        Point point3 = points[triangle.z];

        points[point_i] =   interpolate(point1, point2);
        points[point_i+1] = interpolate(point2, point3);
        points[point_i+2] = interpolate(point3, point1);

        triangles[triangle_i] =   ivec3(triangle.x, point_i,     point_i + 2);
        triangles[triangle_i+1] = ivec3(triangle.y, point_i + 1, point_i    );
        triangles[triangle_i+2] = ivec3(triangle.z, point_i + 2, point_i + 1);
        triangles[triangle_i+3] = ivec3(point_i,    point_i + 1, point_i + 2);
        triangle_i += 4;

        point_i += 3;
      }
    }
  }

  vec3 COLORS[] = {
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0),
    vec3(1.0, 1.0, 0.0),
    vec3(1.0, 0.0, 1.0),
    vec3(0.0, 1.0, 1.0),
    vec3(0.5, 0.0, 0.0),
    vec3(0.0, 0.5, 0.0),
    vec3(0.0, 0.0, 0.5),
    vec3(0.5, 0.5, 0.0),
    vec3(0.5, 0.0, 0.5),
    vec3(0.0, 0.5, 0.5),
    vec3(0.25, 0.0, 0.0),
    vec3(0.0, 0.25, 0.0),
    vec3(0.0, 0.0, 0.25),
    vec3(0.25, 0.25, 0.0),
    vec3(0.25, 0.0, 0.25),
    vec3(0.0, 0.25, 0.25)
  };

  // Emit the triangles
  for (int triangle_id = 0; triangle_id < TESSELATION_NUM_TRIANGLES; triangle_id++) {
    ivec3 first_triangle = triangles[1];
    ivec3 triangle = triangles[triangle_id];
    for (int vertex_id = 0; vertex_id < 3; vertex_id++) {
      Point p = points[triangle[vertex_id]];
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
