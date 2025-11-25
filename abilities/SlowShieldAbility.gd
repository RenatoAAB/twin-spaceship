extends Ability
class_name SlowShieldAbility

@export var shield_health: float = 100.0
@export var shield_scene: PackedScene # Optional visual

var current_shield_health: float
var is_shield_active: bool = false

func _ready() -> void:
	super._ready()
	current_shield_health = shield_health

func _execute() -> void:
	is_shield_active = true
	# Enable visual shield if present
	# Logic to intercept damage would be in the ship's hurtbox or a specific shield hurtbox
	# For this implementation, we will assume the ship checks this ability or we modify the ship's state
	var ship = owner as Node
	if not ship:
		ship = get_parent()
		
	if ship.has_method("activate_shield"):
		ship.activate_shield(current_shield_health)

func _stop() -> void:
	is_shield_active = false
	var ship = owner as Node
	if not ship:
		ship = get_parent()
		
	if ship.has_method("deactivate_shield"):
		ship.deactivate_shield()
