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

func _physics_process(delta: float) -> void:
	var input_vector := _get_input_vector()
	
	if input_vector != Vector2.ZERO:
		# Aplica aceleração na direção do input
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		
		# Rotaciona a nave para olhar na direção do movimento
		if velocity.length() > 0.1:
			var target_angle = velocity.angle()
			rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	else:
		# Aplica fricção para parar a nave quando não há input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

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
