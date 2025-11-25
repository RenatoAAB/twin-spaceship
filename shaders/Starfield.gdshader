shader_type canvas_item;

uniform vec2 resolution = vec2(1152.0, 648.0);
uniform vec2 camera_position = vec2(0.0, 0.0);
uniform float density : hint_range(0.01, 0.2) = 0.05;
uniform float speed_scale : hint_range(0.0, 2.0) = 0.2;

// Pseudo-random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec3 color = vec3(0.0);
    vec2 uv = UV;
    // Correct aspect ratio for the UVs so stars are round
    uv.x *= resolution.x / resolution.y;
    
    // 3 Layers of stars
    // i = 1.0 (Close, Fast, Big) -> i = 3.0 (Far, Slow, Small)
    for(float i = 1.0; i <= 3.0; i++) {
        // Parallax factor: Closer layers move faster
        // i=1 -> speed 1.0
        // i=2 -> speed 0.5
        // i=3 -> speed 0.33
        float parallax = 1.0 / i;
        
        // Grid scale: Closer layers have larger cells (fewer, bigger stars)
        // i=1 -> scale 10.0
        // i=3 -> scale 30.0
        float scale = 10.0 * i;
        
        // Calculate offset based on camera position
        vec2 offset = camera_position * speed_scale * parallax * 0.001;
        
        // Apply scale and offset
        vec2 grid_uv = (uv * scale) + offset;
        vec2 id = floor(grid_uv);
        vec2 f = fract(grid_uv);
        
        // Check neighbor cells to avoid clipping at edges
        for (int y = -1; y <= 1; y++) {
            for (int x = -1; x <= 1; x++) {
                vec2 neighbor = vec2(float(x), float(y));
                vec2 neighbor_id = id + neighbor;
                
                // Random value for this grid cell
                float r = random(neighbor_id);
                
                // Determine if a star exists in this cell
                if (r < density) {
                    // Random position within the cell
                    vec2 pos = vec2(random(neighbor_id + vec2(1.0)), random(neighbor_id + vec2(2.0)));
                    
                    // Distance from pixel to star center
                    // Star position relative to current cell ID is neighbor + pos
                    // Pixel position relative to current cell ID is f
                    vec2 diff = neighbor + pos - f;
                    float dist = length(diff);
                    
                    // Star shape (glow)
                    // Closer stars (low i) should be bigger/brighter
                    float glow_radius = 0.02 * (1.0 / sqrt(i)); 
                    
                    // Use a non-singular falloff or clamp the maximum brightness to avoid HDR artifacts
                    // Old formula: float brightness = glow_radius / max(dist, 0.0001);
                    // New formula: Soft falloff that doesn't explode to infinity
                    float brightness = glow_radius / (dist + 0.005);
                    
                    // Soft edge
                    brightness = pow(brightness, 1.5);
                    
                    // Clamp brightness to a reasonable HDR maximum (e.g. 5.0) to prevent blinding bloom
                    brightness = min(brightness, 5.0);
                    
                    // Twinkle effect
                    // Use a separate random value for twinkle characteristics
                    float twinkle_speed = random(neighbor_id + vec2(3.0)) * 3.0 + 0.5; // Random speed
                    float twinkle_offset = random(neighbor_id + vec2(4.0)) * 10.0; // Random phase
                    
                    // Only some stars twinkle significantly
                    float twinkle_amount = 0.0;
                    if (random(neighbor_id + vec2(6.0)) > 0.7) { // 30% chance to twinkle
                         twinkle_amount = 0.5;
                    }
                    
                    float twinkle = 1.0 - (twinkle_amount * 0.5) + (twinkle_amount * 0.5 * sin(TIME * twinkle_speed + twinkle_offset));
                    brightness *= twinkle;
                    
                    // Color variation (Blueish to White to Yellowish)
                    vec3 star_color = mix(vec3(0.7, 0.8, 1.0), vec3(1.0, 0.9, 0.7), random(neighbor_id + vec2(5.0)));
                    
                    // Add to final color
                    color += star_color * brightness;
                }
            }
        }
    }
    
    // Deep space background color
    vec3 bg_color = vec3(0.01, 0.01, 0.03);
    
    COLOR = vec4(bg_color + color, 1.0);
}
