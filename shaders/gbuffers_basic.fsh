#version 450 compatibility

// From Optifine/Minecraft
uniform sampler2D texture;
uniform sampler2D lightmap;

uniform sampler2DShadow shadow;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 cameraPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

// From Vertex Shader
in vec3 normal_vs;
in vec4 biome_specific_color_vs;
in vec2 texture_coord_vs;
in vec4 screen_coord_vs;
in vec2 light_levels_vs;

// Outputs
layout(location = 0) out vec4 color_fs;
layout(location = 2) out vec3 normal_fs;

vec3 screen_to_world_space(vec4 screen_pos) {
    vec4 world_pos = gbufferModelViewInverse * gbufferProjectionInverse * screen_pos;
    world_pos.xyz += cameraPosition;
    return world_pos.xyz;
}

vec3 world_to_shadow_space(vec3 world_pos) {
    vec4 shadow_pos = (shadowProjection * shadowModelView * vec4(world_pos - cameraPosition, 1.0));
    shadow_pos /= shadow_pos.w;

    return shadow_pos.xyz * 0.5 + 0.5;
}

void main() {
    normal_fs = normal_vs;

    const vec4 texture_color = texture2D(texture, texture_coord_vs);
    const vec4 color = texture_color * biome_specific_color_vs;

    const vec4 screen_pos = screen_coord_vs;
    const vec3 world_pos = screen_to_world_space(screen_pos);
    const vec3 shadow_pos = world_to_shadow_space(world_pos);

    const vec4 shadowmap_distance = shadow2D(shadow, shadow_pos);
    vec2 light_levels_shadows = light_levels_vs;

    if (shadowmap_distance.x + 0.0001 < shadow_pos.z) {
        light_levels_shadows.y = 0;
    }

    vec4 light = texture2D(lightmap, light_levels_shadows / 255);

    color_fs = light * color;
}
