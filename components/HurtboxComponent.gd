extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent

func _ready() -> void:
	if health_component == null:
		# Try to find it in parent
		var parent = get_parent()
		if parent:
			health_component = parent.find_child("HealthComponent", false)
			
	if health_component == null:
		push_warning("HurtboxComponent needs a HealthComponent")

func take_damage(amount: float) -> void:
	# Allow parent to intercept damage (e.g. for shields)
	var parent = get_parent()
	if parent and parent.has_method("intercept_damage"):
		var result = parent.intercept_damage(amount)
		amount = result
		
	if amount > 0 and health_component:
		health_component.damage(amount)
