shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.1) = 0.05;
uniform float size : hint_range(0.0, 1.0) = 0.5;
uniform float thickness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	
	// Create a ring
	float mask = smoothstep(size - thickness, size, dist) * smoothstep(size + thickness, size, dist);
	
	// Distort UVs
	vec2 disp = normalize(UV - center) * strength * mask;
	
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	// Debug: COLOR = vec4(mask, 0.0, 0.0, 1.0);
}
