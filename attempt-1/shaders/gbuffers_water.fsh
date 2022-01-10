#version 450 compatibility

#define M_PI 3.1415926535897932384626433832795

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float sunAngle;

// From Vertex Shader
in vec2 texcoord_vs;
in vec4 biome_specific_color_vs;
in vec2 light_levels_vs;
in vec3 normal_vs;
in vec3 direction_vs;
in vec3 position_vs;

// Outputs
layout(location = 0) out vec4 color_fs;

vec3 getSunMoonPosition() {
    float angle = sunAngle * 2 * M_PI;

    if (angle > M_PI) {
        angle = angle - M_PI;
    }

    return vec3(cos(angle), sin(angle), 0.0);
}

void main() {
    const vec4 texture = texture2D(texture, texcoord_vs);
    const vec4 texture_color = texture * biome_specific_color_vs;
    const vec4 texture_color_light = texture2D(lightmap, light_levels_vs / 255) * texture_color;

    vec3 n = normalize(normal_vs);
    vec3 l = normalize(getSunMoonPosition());
    vec3 v = -normalize(direction_vs);
    vec3 h = (v + l) / length(v + l);

    float Ia = 0.1;
    float I = 1.0; // TODO: get from sun
    float p = 5000;

    color_fs = vec4((
        (texture_color_light.rgb * Ia) +
        (texture_color_light.rgb * I * max(0, dot(n, l)))
    ), texture_color_light.a);
    color_fs += I * vec4(pow(max(0, dot(n, h)), p));
}
