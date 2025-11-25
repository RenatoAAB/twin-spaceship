extends Node
class_name Ability

signal activated
signal deactivated

@export var cooldown: float = 0.0
var is_active: bool = false
var can_activate: bool = true
var timer: Timer

func _ready() -> void:
	if cooldown > 0:
		timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = cooldown
		timer.timeout.connect(_on_cooldown_finished)
		add_child(timer)

func activate() -> void:
	if not can_activate:
		return
	is_active = true
	activated.emit()
	print("[Signal] Ability: activated emitted for ", name)
	_execute()

func deactivate() -> void:
	is_active = false
	deactivated.emit()
	print("[Signal] Ability: deactivated emitted for ", name)
	_stop()

func _execute() -> void:
	pass

func _stop() -> void:
	pass

func start_cooldown() -> void:
	if timer:
		can_activate = false
		timer.start()

func _on_cooldown_finished() -> void:
	can_activate = true
