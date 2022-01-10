#version 450 compatibility

uniform sampler2D colortex0;

uniform float viewWidth;
uniform float viewHeight;

layout(location = 0) out vec4 color;

void main() {
  color = texture2D(colortex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight));
}
