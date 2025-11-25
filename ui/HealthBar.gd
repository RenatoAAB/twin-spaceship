extends Control

@export var health_component: HealthComponent
@export var progress_bar: ProgressBar

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		# Initialize
		_on_health_changed(health_component.current_health, health_component.max_health)

func _on_health_changed(current: float, max_value: float) -> void:
	if progress_bar:
		progress_bar.max_value = max_value
		progress_bar.value = current
