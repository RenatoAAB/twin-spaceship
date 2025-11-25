extends Node2D

@export var duration: float = 0.5
@export var max_size: float = 0.8
@export var max_strength: float = 0.05

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	var mat = color_rect.material as ShaderMaterial
	if not mat:
		queue_free()
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(v): mat.set_shader_parameter("size", v), 0.0, max_size, duration)
	tween.tween_method(func(v): mat.set_shader_parameter("strength", v), max_strength, 0.0, duration)
	tween.chain().tween_callback(queue_free)
