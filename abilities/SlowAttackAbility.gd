extends Ability
class_name SlowAttackAbility

@export var projectile_scene: PackedScene
@export var max_charge_time: float = 2.0
@export var min_charge_time: float = 0.5
@export var base_damage: float = 20.0
@export var max_damage: float = 100.0

var charge_start_time: float = 0.0
var is_charging: bool = false

func _execute() -> void:
	is_charging = true
	charge_start_time = Time.get_ticks_msec() / 1000.0
	print("Charging laser...")

func _stop() -> void:
	if not is_charging:
		return
		
	is_charging = false
	var current_time = Time.get_ticks_msec() / 1000.0
	var charge_duration = current_time - charge_start_time
	
	if charge_duration >= min_charge_time:
		_fire_laser(charge_duration)
	else:
		print("Charge too short")

func _fire_laser(charge_duration: float) -> void:
	if projectile_scene == null:
		return
		
	var charge_ratio = min(charge_duration / max_charge_time, 1.0)
	var damage = lerp(base_damage, max_damage, charge_ratio)
	var scale_mult = lerp(1.0, 3.0, charge_ratio)
	
	var ship = owner as Node2D
	if not ship:
		ship = get_parent() as Node2D
		
	var proj = projectile_scene.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = ship.global_position
	proj.rotation = ship.rotation
	proj.direction = Vector2.RIGHT.rotated(ship.rotation)
	proj.scale = Vector2(scale_mult, scale_mult)
	
	if "damage" in proj:
		proj.damage = damage
		
	print("Fired laser with damage: ", damage)
