extends Node
class_name HealthComponent

signal health_changed(new_health: float, max_health: float)
signal died

@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	print("[Signal] HealthComponent: health_changed emitted (", current_health, "/", max_health, ")")

func damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	print("[Signal] HealthComponent: health_changed emitted (", current_health, "/", max_health, ")")
	
	if current_health <= 0:
		died.emit()
		print("[Signal] HealthComponent: died emitted")

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	print("[Signal] HealthComponent: health_changed emitted (", current_health, "/", max_health, ")")
