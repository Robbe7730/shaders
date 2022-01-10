void tangent(in vec3 N, out vec3 T, out vec3 B)
{
  vec3 c1 = cross(N, vec3(0.0, 0.0, 1.0));
  vec3 c2 = cross(N, vec3(0.0, 1.0, 0.0));

  if (length(c1)>length(c2)) {
      T = c1;
  } else {
      T = c2;
  }

  T = normalize(T);

  B = cross(N, T);
  B = normalize(B);
}

