extends CharacterBody2D

enum JoystickSide {
	LEFT,
	RIGHT
}

@export_category("Configuração de Controle")
@export var joystick_side: JoystickSide = JoystickSide.LEFT
@export var device_id: int = 0

@export_category("Parâmetros da Nave")
@export var max_speed: float = 600.0
@export var acceleration: float = 1500.0
@export var friction: float = 1000.0
@export var rotation_speed: float = 10.0

@export_category("Auto Aim")
@export var auto_aim_enabled: bool = false
@export var auto_aim_radius: float = 600.0
@export var show_debug_draw: bool = false

@export_category("Habilidades")
@export var primary_ability: Ability
@export var secondary_ability: Ability

# Dash state
var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_velocity: Vector2 = Vector2.ZERO

# Shield state
var shield_active: bool = false
var shield_health: float = 0.0

# Input state tracking
var _was_primary_pressed: bool = false
var _was_secondary_pressed: bool = false

func _physics_process(delta: float) -> void:
	if show_debug_draw:
		queue_redraw()

	if is_dashing:
		_process_dash(delta)
	else:
		_process_movement(delta)
		_process_rotation(delta)
		
	_process_abilities()
	move_and_slide()

func _process_movement(delta: float) -> void:
	var input_vector := _get_input_vector()
	
	if input_vector != Vector2.ZERO:
		# Aplica aceleração na direção do input
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		# Aplica fricção para parar a nave quando não há input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _process_rotation(delta: float) -> void:
	var target_angle = rotation # Default to current
	var should_rotate = false
	
	# Auto-aim logic
	if auto_aim_enabled:
		var target = _get_closest_enemy_in_range()
		if target:
			target_angle = (target.global_position - global_position).angle()
			should_rotate = true
	
	# Fallback to movement direction if no target or auto-aim disabled
	if not should_rotate and velocity.length() > 0.1:
		target_angle = velocity.angle()
		should_rotate = true
		
	if should_rotate:
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func _get_closest_enemy_in_range() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
		
	var closest = null
	var min_dist = auto_aim_radius * auto_aim_radius # Compare squared distance
	
	for enemy in enemies:
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
			
	return closest

func _draw() -> void:
	if show_debug_draw and auto_aim_enabled:
		draw_circle(Vector2.ZERO, auto_aim_radius, Color(1, 0, 0, 0.1))
		draw_arc(Vector2.ZERO, auto_aim_radius, 0, TAU, 32, Color(1, 0, 0, 0.5), 2.0)

func _process_dash(delta: float) -> void:
	velocity = dash_velocity
	dash_time_left -= delta
	if dash_time_left <= 0:
		is_dashing = false

func _process_abilities() -> void:
	var primary_down = false
	var secondary_down = false
	
	if joystick_side == JoystickSide.LEFT:
		# L1 (Button) and L2 (Axis)
		primary_down = Input.is_joy_button_pressed(device_id, JOY_BUTTON_LEFT_SHOULDER)
		secondary_down = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT) > 0.5
	else:
		# R1 (Button) and R2 (Axis)
		# Mapping: Attack (Primary) = R1, Defense (Secondary) = R2 based on prompt interpretation
		# "R1 e R2 para a nave caça"
		# Let's assume R1 is Primary (Attack) and R2 is Secondary (Defense)
		primary_down = Input.is_joy_button_pressed(device_id, JOY_BUTTON_RIGHT_SHOULDER)
		secondary_down = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT) > 0.5

	# Handle Primary Ability
	if primary_ability:
		if primary_down and not _was_primary_pressed:
			primary_ability.activate()
		elif not primary_down and _was_primary_pressed:
			primary_ability.deactivate()
			
	# Handle Secondary Ability
	if secondary_ability:
		if secondary_down and not _was_secondary_pressed:
			secondary_ability.activate()
		elif not secondary_down and _was_secondary_pressed:
			secondary_ability.deactivate()
			
	_was_primary_pressed = primary_down
	_was_secondary_pressed = secondary_down

func _get_input_vector() -> Vector2:
	var x_axis: float = 0.0
	var y_axis: float = 0.0
	
	if joystick_side == JoystickSide.LEFT:
		x_axis = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
		y_axis = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	else:
		x_axis = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
		y_axis = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		
	var vector = Vector2(x_axis, y_axis)
	
	# Deadzone para evitar drift do controle
	if vector.length() < 0.1:
		return Vector2.ZERO
		
	return vector.normalized()

# --- Ability Callbacks ---

func start_dash(speed: float, duration: float) -> void:
	is_dashing = true
	dash_time_left = duration
	# Dash in current movement direction or forward
	var dir = velocity.normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT.rotated(rotation)
	dash_velocity = dir * speed

func activate_shield(health: float) -> void:
	shield_active = true
	shield_health = health
	print("Shield activated with health: ", shield_health)

func deactivate_shield() -> void:
	shield_active = false
	print("Shield deactivated")

func intercept_damage(amount: float) -> float:
	if shield_active and shield_health > 0:
		var damage_to_take = min(shield_health, amount)
		shield_health -= damage_to_take
		amount -= damage_to_take
		print("Shield absorbed: ", damage_to_take, " Remaining shield: ", shield_health)
		if shield_health <= 0:
			deactivate_shield()
	return amount

func _ready() -> void:
	add_to_group("players")
