extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_radius: float = 500.0

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_spawn_enemy)
	add_child(timer)

func _spawn_enemy() -> void:
	if enemy_scene == null:
		return
		
	var enemy = enemy_scene.instantiate()
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_radius
	
	# Spawn relative to camera or center? Let's spawn relative to this node
	enemy.position = spawn_pos
	add_child(enemy)
