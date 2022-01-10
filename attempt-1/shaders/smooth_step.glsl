float smooth_step(float f)
{
  return 3*pow(f, 2) - 2*pow(f, 3);
}

vec3 smooth_step(vec3 f)
{
  return vec3(
    smooth_step(f.x),
    smooth_step(f.y),
    smooth_step(f.z)
  );
}
