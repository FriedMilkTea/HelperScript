shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform vec2 size = vec2(0.1, 0.1);
uniform vec4 shade_color : source_color = vec4(0.0, 0.0, 0.0, 0.7);
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 0.1) = 0.005;
uniform float pulse_speed : hint_range(0.1, 5.0) = 5.0;
uniform float pulse_strength : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 scaled_uv = (uv - center) / size;
    
    vec2 abs_scaled_uv = abs(scaled_uv);
    float max_dim = max(abs_scaled_uv.x, abs_scaled_uv.y);
    
    // Add pulsing effect
    float pulse = sin(TIME * pulse_speed) * pulse_strength;
    float inner_rect = step(max_dim, 1.0 + pulse);
    float outer_rect = step(max_dim, 1.0 + pulse + outline_width / length(size));
    
    float outline = outer_rect - inner_rect;
    
    // Create a cutout effect
    vec4 color = mix(shade_color, vec4(0.0), inner_rect);  // Transparent inside
    color = mix(color, outline_color, outline);  // Add outline
    
    COLOR = color;
}