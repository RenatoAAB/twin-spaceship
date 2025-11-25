extends Node2D
class_name TrailComponent

@export var length_seconds: float = 0.2
@export var min_speed_for_trail: float = 10.0
@export var width: float = 20.0
@export var trail_color: Color = Color(0.0, 0.8, 1.0, 1.0)

@onready var line: Line2D = $Line2D

var point_queue: Array[Dictionary] = [] # {pos: Vector2, time: float}

func _ready() -> void:
	line.top_level = true
	line.clear_points()
	line.width = width
	
	# Apply color to shader if possible, or modulate
	if line.material is ShaderMaterial:
		(line.material as ShaderMaterial).set_shader_parameter("trail_color", trail_color)
	else:
		line.default_color = trail_color

func _process(delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Add new point
	# Only add if we moved enough or just always add?
	# Always adding creates a smooth trail even when standing still (it bunches up), 
	# but for an engine trail, we want it to appear only when moving or just exist at the back?
	# The user said "trail é maior se a velocidade é maior".
	# If we use time-based decay, the length in pixels is naturally Speed * Time.
	
	point_queue.append({
		"pos": global_position,
		"time": current_time
	})
	line.add_point(global_position)
	
	# Remove old points
	while point_queue.size() > 0:
		var p = point_queue[0]
		if current_time - p.time > length_seconds:
			point_queue.pop_front()
			if line.get_point_count() > 0:
				line.remove_point(0)
		else:
			break
			
	# Optional: Adjust width based on speed?
	# The prompt says "trail é maior se a velocidade é maior".
	# The length is already handled by speed * time.
	# Maybe width or intensity could change too?
	# Let's stick to length for now as it's the most physical interpretation.
