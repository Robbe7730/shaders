#include "random2.glsl"

vec3 random_direction(vec3 seed)
{
  vec2 params = random2(seed);
  return vec3(
    cos(params[0]*2*M_PI)*sin(params[1]*2*M_PI),
    sin(params[0]*2*M_PI)*sin(params[1]*2*M_PI),
    cos(params[1]*2*M_PI)
  );
}
