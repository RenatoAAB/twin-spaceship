extends Ability
class_name FighterAttackAbility

signal projectile_fired

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.1
@export var projectile_speed: float = 1000.0

var fire_timer: Timer

func _ready() -> void:
	super._ready()
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_fire)
	add_child(fire_timer)

func _execute() -> void:
	fire_timer.start()
	_fire() # Fire immediately

func _stop() -> void:
	fire_timer.stop()

func _fire() -> void:
	var ship = owner as Node2D
	if not ship:
		ship = get_parent() as Node2D
	
	if not ship:
		return

	# Always shoot forward based on ship rotation
	var direction = Vector2.RIGHT.rotated(ship.rotation)
		
	if projectile_scene:
		var proj = projectile_scene.instantiate()
			
		get_tree().root.add_child(proj)
		proj.global_position = ship.global_position
		
		proj.direction = direction
		proj.rotation = direction.angle()
		proj.speed = projectile_speed
		
		projectile_fired.emit()
