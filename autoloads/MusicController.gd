extends Node

signal beat(beat_number: int)
signal bar(bar_number: int)

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4

var _time: float = 0.0
var _beat_interval: float = 0.0
var _current_beat: int = 0
var _current_bar: int = 0
var _playing: bool = false

func _ready() -> void:
	_update_interval()
	# Start automatically for now, or wait for call
	play()

func play() -> void:
	_playing = true
	_time = 0.0
	_current_beat = 0
	_current_bar = 0

func stop() -> void:
	_playing = false

func _process(delta: float) -> void:
	if not _playing:
		return
		
	_time += delta
	if _time >= _beat_interval:
		_time -= _beat_interval
		_current_beat += 1
		beat.emit(_current_beat)
		
		if _current_beat % beats_per_bar == 0:
			_current_bar += 1
			bar.emit(_current_bar)

func _update_interval() -> void:
	if bpm > 0:
		_beat_interval = 60.0 / bpm

func set_bpm(new_bpm: float) -> void:
	bpm = new_bpm
	_update_interval()

# Helper to get time until next beat (for quantization)
func time_to_next_beat() -> float:
	return _beat_interval - _time
