extends Node
class_name FeedbackComponent

@export_category("Visual")
@export var sprite: CanvasItem
@export var flash_color: Color = Color.WHITE
@export var flash_duration: float = 0.1

@export_category("Shake")
@export var shake_intensity: float = 5.0
@export var shake_duration: float = 0.2

var _original_modulate: Color
var _is_flashing: bool = false

func _ready() -> void:
	if sprite:
		_original_modulate = sprite.modulate

func play_damage_feedback() -> void:
	flash()
	request_shake()

func flash() -> void:
	if not sprite or _is_flashing:
		return
		
	_is_flashing = true
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", flash_color, 0.05)
	tween.tween_property(sprite, "modulate", _original_modulate, flash_duration)
	tween.tween_callback(func(): _is_flashing = false)

func request_shake() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(shake_intensity / 100.0) # Normalizando se necessário
	elif camera and camera.has_method("shake"):
		camera.shake(shake_intensity, shake_duration)
