extends CharacterBody2D
class_name Enemy

@export var speed: float = 200.0
@export var health_component: HealthComponent

func _ready() -> void:
	if health_component:
		health_component.died.connect(_on_died)
	
	# Add to enemies group for auto-aim
	add_to_group("enemies")

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

func _on_died() -> void:
	queue_free()
