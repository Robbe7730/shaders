#include "random_direction.glsl"
#include "smooth_step.glsl"
float perlin_noise(vec3 st)
{
  vec3 p0 = vec3(
    int(st.x),
    int(st.y),
    int(st.z)
  );

  float influences[8];

  for (int i = 0; i < 8; i++) {
    vec3 p = vec3(
      p0.x + (((i & 1) == 0)? 0 : 1),
      p0.y + (((i & 2) == 0)? 0 : 1),
      p0.z + (((i & 4) == 0)? 0 : 1)
    );
    vec3 gradient_vector = random_direction(p);
    vec3 distance_vector = vec3(
      st.x - p.x,
      st.y - p.y,
      st.z - p.z
    );
    float influence = dot(gradient_vector, distance_vector);
    influences[i] = influence;
  }

  float u = smooth_step(st.x - int(st.x));
  float v = smooth_step(st.y - int(st.y));
  float w = smooth_step(st.z - int(st.z));

  float x1 = mix(influences[0], influences[1], u);
  float x2 = mix(influences[2], influences[3], u);
  float x3 = mix(influences[4], influences[5], u);
  float x4 = mix(influences[6], influences[7], u);

  float y1 = mix(x1, x2, v);
  float y2 = mix(x3, x4, v);

  float average = mix(y1, y2, w);

  return average;
}
