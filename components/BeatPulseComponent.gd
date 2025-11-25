extends Node
class_name BeatPulseComponent

@export var target: CanvasItem
@export var pulse_scale: float = 1.1
@export var pulse_duration: float = 0.1
@export var pulse_on_beat: bool = true
@export var pulse_on_bar: bool = false

var _original_scale: Vector2
var _tween: Tween

func _ready() -> void:
	if target:
		_original_scale = target.scale
	else:
		# Try to use parent if no target specified
		var parent = get_parent()
		if parent is CanvasItem:
			target = parent
			_original_scale = target.scale
	
	# Connect to MusicController signals
	MusicController.beat.connect(_on_beat)
	MusicController.bar.connect(_on_bar)

func _on_beat(_beat_number: int) -> void:
	if pulse_on_beat:
		_pulse()

func _on_bar(_bar_number: int) -> void:
	if pulse_on_bar:
		_pulse()

func _pulse() -> void:
	if not target:
		return
		
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(target, "scale", _original_scale * pulse_scale, pulse_duration * 0.3)
	_tween.tween_property(target, "scale", _original_scale, pulse_duration * 0.7)
