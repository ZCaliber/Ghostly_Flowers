shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float radius: hint_range(0.0, 10.0) = 5.0;

void fragment() {
    vec2 offset = vec2(radius) / vec2(textureSize(SCREEN_TEXTURE, 0));
    vec4 color = vec4(0.0);

    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-offset.x, -offset.y)) * 0.0625;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( offset.x, -offset.y)) * 0.0625;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-offset.x,  offset.y)) * 0.0625;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( offset.x,  offset.y)) * 0.0625;

    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-offset.x, 0.0)) * 0.125;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( offset.x, 0.0)) * 0.125;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -offset.y)) * 0.125;
    color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0,  offset.y)) * 0.125;

    color += texture(SCREEN_TEXTURE, SCREEN_UV) * 0.25;

    COLOR = color;
}
