extends Ability
class_name FighterDashAbility

@export var dash_speed: float = 2000.0
@export var duration: float = 0.5

func _execute() -> void:
	var ship = owner as CharacterBody2D
	if not ship:
		ship = get_parent() as CharacterBody2D
		
	if ship:
		# Make invulnerable
		var hurtbox = ship.find_child("HurtboxComponent", true, false)
		if hurtbox:
			hurtbox.set_deferred("monitorable", false)
			hurtbox.set_deferred("monitoring", false)
			
		# Apply dash velocity (simple implementation)
		# Note: This might be overridden by the controller's physics process
		# Ideally the controller should check for a "dashing" state
		# For now, we will try to set a flag on the ship if it exists, or just rely on the invulnerability
		# and maybe the user can implement the movement override in the controller
		
		if ship.has_method("start_dash"):
			ship.start_dash(dash_speed, duration)
			
		# End dash after duration
		await get_tree().create_timer(duration).timeout
		
		if hurtbox:
			hurtbox.set_deferred("monitorable", true)
			hurtbox.set_deferred("monitoring", true)
			
		start_cooldown()
		deactivate()
