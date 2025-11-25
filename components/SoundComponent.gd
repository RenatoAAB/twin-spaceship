extends Node
class_name SoundComponent

@export_category("Sounds")
@export var move_sound: AudioStream
@export var hit_sound: AudioStream
@export var destroy_sound: AudioStream
@export var ability_1_sound: AudioStream
@export var ability_2_sound: AudioStream
@export var projectile_sound: AudioStream # Som individual para cada projétil disparado

@export_category("Settings")
@export var pitch_randomness: float = 0.1
@export var quantize: bool = false
@export var quantize_subdivision: int = 4 # 1/16th notes by default if quantized

var _move_player: AudioStreamPlayer2D

func play_move() -> void:
	if not move_sound: return
	
	if not _move_player:
		_move_player = AudioStreamPlayer2D.new()
		_move_player.stream = move_sound
		_move_player.bus = "SFX"
		add_child(_move_player)
		
	if not _move_player.playing:
		_move_player.play()

func stop_move() -> void:
	if _move_player and _move_player.playing:
		_move_player.stop()

func move_sound_playing() -> bool:
	return _move_player and _move_player.playing

func play_hit() -> void:
	_play(hit_sound)

func play_destroy() -> void:
	# Para sons de destruição, usamos o AudioManager global para garantir que o som termine
	# mesmo que o objeto pai seja removido da árvore.
	if destroy_sound:
		AudioManager.play_sound_2d(destroy_sound, get_parent().global_position, 0.0, _get_random_pitch())

func play_ability_1() -> void:
	_play(ability_1_sound)

func play_ability_2() -> void:
	_play(ability_2_sound)

func play_projectile() -> void:
	_play(projectile_sound)

func _play(stream: AudioStream) -> void:
	if not stream:
		return

	if quantize:
		# Schedule sound for next subdivision
		var time_to_next = MusicController.time_to_next_beat()
		# Simple quantization to next beat for now, can be improved for subdivisions
		# For now, let's just play it immediately but maybe we can add a delay?
		# Actually, true quantization requires scheduling.
		# Let's use a timer for the delay.
		var delay = time_to_next
		if delay > 0.01: # If it's very close, play now
			get_tree().create_timer(delay).timeout.connect(func():
				AudioManager.play_sound_2d(stream, get_parent().global_position, 0.0, _get_random_pitch())
			)
			return

	AudioManager.play_sound_2d(stream, get_parent().global_position, 0.0, _get_random_pitch())

func _get_random_pitch() -> float:
	return 1.0 + randf_range(-pitch_randomness, pitch_randomness)
