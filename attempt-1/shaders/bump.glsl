#include "perlin_noise.glsl"

float bump_height(vec3 s)
{
  // The abs() here is a hack to get negative x/y working
    return clamp(perlin_noise(abs(s)) / 100, -0.1, 0.1);
}

vec3 bump_position(float frameTimeCounter, vec3 s)
{
  float bump = bump_height(vec3(s.x, frameTimeCounter, s.z));
  return s + bump * s;
}
