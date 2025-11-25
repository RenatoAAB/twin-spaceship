extends Area2D
class_name Projectile

@export var speed: float = 800.0
@export var damage: float = 10.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Ensure we hit world (1) and enemies (4)
	collision_mask = 5 
	
	# Setup auto-destruction
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	# Setup collision
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		# Check if we hit a player hurtbox (optional safety, though mask should handle it)
		var entity = area.owner
		if entity and entity.is_in_group("players"):
			return
			
		area.take_damage(damage)
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Don't destroy on player contact (spawn point)
	if body.is_in_group("players"):
		return
		
	# Destroy on hitting walls etc
	queue_free()
