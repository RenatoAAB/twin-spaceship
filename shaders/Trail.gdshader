shader_type canvas_item;

uniform vec4 trail_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float turbulence_strength : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	// UV.x = 0 (start/head) -> 1 (end/tail) usually in Line2D with proper texture mode
	// But Godot Line2D UVs can be tricky. 
	// Let's assume UV.x follows the line length.
	
	// Fade out towards the tail
	// UV.x = 0 is the tail (oldest point), UV.x = 1 is the head (newest point/ship)
	float fade = smoothstep(0.0, 1.0, UV.x);
	
	// Taper the width (alpha) at the edges (UV.y 0..1)
	float width_dist = abs(UV.y - 0.5) * 2.0;
	float side_fade = 1.0 - width_dist;
	side_fade = pow(side_fade, 2.0); // Sharpen the core
	
	// Add some "engine pulse" or turbulence
	float noise = sin(UV.x * 20.0 - TIME * 20.0) * turbulence_strength;
	float pulse = 1.0 + noise;
	
	vec4 final_color = trail_color;
	final_color.a *= fade * side_fade * pulse;
	
	COLOR = final_color;
}
