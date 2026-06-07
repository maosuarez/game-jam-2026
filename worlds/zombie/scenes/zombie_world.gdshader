shader_type canvas_item;

uniform sampler2D existing_screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_speed : hint_range(0.0, 10.0) = 5.0;

void fragment() {
    float time = TIME * glitch_speed;
    
    float noise = fract(sin(dot(
        vec2(floor(SCREEN_UV.y * 20.0), floor(time * 10.0)),
        vec2(12.9898, 78.233)
    )) * 43758.5453);
    
    float offset = (noise - 0.5) * glitch_intensity * 0.1;
    
    vec2 uv_r = SCREEN_UV + vec2(offset * 1.5, 0.0);
    vec2 uv_g = SCREEN_UV + vec2(offset, 0.0);
    vec2 uv_b = SCREEN_UV + vec2(-offset * 1.5, 0.0);
    
    float r = textureLod(existing_screen_texture, uv_r, 0.0).r;
    float g = textureLod(existing_screen_texture, uv_g, 0.0).g;
    float b = textureLod(existing_screen_texture, uv_b, 0.0).b;
    
    COLOR = vec4(r, g, b, 1.0);
}