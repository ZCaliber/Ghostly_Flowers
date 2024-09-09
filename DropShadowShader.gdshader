shader_type canvas_item;

uniform vec2 shadow_offset = vec2(3.0, 3.0); // Shadow offset
uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5); // Shadow color (black with alpha)

void fragment() {
    // Main text color (inherited from the texture)
    vec4 main_text = texture(TEXTURE, SCREEN_UV);

    // Calculate shadow position and shadow color
    vec2 shadow_pos = SCREEN_UV + (shadow_offset / SCREEN_PIXEL_SIZE);
    vec4 shadow = texture(TEXTURE, shadow_pos) * shadow_color;

    // Display shadow and text together, prioritizing text visibility
    COLOR = max(shadow, main_text);
}