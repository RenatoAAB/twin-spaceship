extends Node

# Dicionário para armazenar referências a streams de áudio carregados
var sounds: Dictionary = {}
var music_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

# Toca um som globalmente (não posicional)
func play_sound(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not stream:
		return
		
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

# Toca um som em uma posição específica (2D)
func play_sound_2d(stream: AudioStream, position: Vector2, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not stream:
		return
		
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "SFX"
	player.max_distance = 2000 # Ajuste conforme necessário
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

# Toca música de fundo
func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return
		
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(func(): 
			music_player.stream = stream
			music_player.play()
			music_player.volume_db = 0.0 # Reset volume
		)
	else:
		music_player.stream = stream
		music_player.play()
