extends CharacterBody2D
class_name Enemy

# Components
var sound_component: SoundComponent
var particle_component: ParticleSpawnerComponent
var feedback_component: FeedbackComponent

@export var speed: float = 200.0
@export var health_component: HealthComponent
@export var death_distortion_scene: PackedScene

func _ready() -> void:
	sound_component = get_node_or_null("SoundComponent")
	particle_component = get_node_or_null("ParticleSpawnerComponent")
	feedback_component = get_node_or_null("FeedbackComponent")

	if health_component:
		health_component.died.connect(_on_died)
		health_component.health_changed.connect(_on_health_changed)
	
	# Add to enemies group for auto-aim
	add_to_group("enemies")

func _on_health_changed(_current: float, _max: float) -> void:
	if feedback_component:
		feedback_component.play_damage_feedback()
	if sound_component:
		sound_component.play_hit()

func _on_died() -> void:
	if sound_component:
		sound_component.play_destroy()
	if particle_component:
		particle_component.spawn_destroy(global_position)
	
	# Spawn distortion wave on death
	if death_distortion_scene:
		var distortion = death_distortion_scene.instantiate()
		distortion.global_position = global_position
		get_tree().current_scene.add_child(distortion)
	
	queue_free()

func _physics_process(delta: float) -> void:
	var target = _get_closest_player()
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		rotation = velocity.angle()

func _get_closest_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return null
		
	var closest_player = null
	var closest_dist = INF
	
	for player in players:
		var dist = global_position.distance_squared_to(player.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_player = player
			
	return closest_player
