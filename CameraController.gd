extends Camera2D

signal point_of_interest_completed(point: Vector2)

@export var target_paths: Array[NodePath]
@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.5
@export var margin_min: Vector2 = Vector2(150, 150)
@export var margin_max: Vector2 = Vector2(400, 400)
@export var zoom_speed: float = 2.0
@export var move_speed: float = 5.0

@export var focus_enter_duration: float = 1.0
@export var focus_hold_duration: float = 0.8
@export var focus_return_duration: float = 1.0
@export var focus_speed_multiplier: float = 1.35
@export var focus_zoom_speed_multiplier: float = 1.4

@export var debug_draw_bounds: bool = true
@export var debug_enable_runtime_input: bool = true
@export var debug_trigger_key: Key = Key.KEY_F3
@export var debug_random_radius: float = 900.0
@export var debug_use_mouse_position: bool = true
@export var debug_base_bounds_color: Color = Color(0.2, 0.9, 0.4, 0.8)
@export var debug_focus_bounds_color: Color = Color(1.0, 0.6, 0.1, 0.8)
@export var debug_interest_color: Color = Color(1.0, 0.2, 0.2, 0.9)

enum FocusState { IDLE, ENTERING, HOLD, RETURNING }

var _focus_state: FocusState = FocusState.IDLE
var _focus_timer: float = 0.0
var _interest_queue: Array[Vector2] = []
var _active_interest_point: Vector2 = Vector2.ZERO
var _has_active_interest: bool = false
var _rng := RandomNumberGenerator.new()

var _debug_last_base_bounds: Rect2 = Rect2()
var _debug_last_focus_bounds: Rect2 = Rect2()
var _debug_has_focus_bounds: bool = false

# Shake variables
var _shake_strength: float = 0.0
var _shake_decay: float = 5.0

func _ready() -> void:
	_rng.randomize()

func _process(delta: float) -> void:
	var targets := _get_targets()
	if targets.is_empty():
		return

	_ensure_focus_cycle_started()

	var base_bounds = _get_bounding_box(targets)
	var focus_bounds = base_bounds.expand(_active_interest_point) if _has_active_interest else base_bounds
	var base_center = base_bounds.get_center()
	var focus_center = focus_bounds.get_center()
	var base_zoom = _calculate_zoom(base_bounds)
	var focus_zoom = _calculate_zoom(focus_bounds)
	var focus_blend = _get_focus_blend()
	var target_pos = base_center.lerp(focus_center, focus_blend)
	var target_zoom = lerp(base_zoom, focus_zoom, focus_blend)
	var in_transition := _focus_state != FocusState.IDLE
	var move_lerp: float = clamp(move_speed * (focus_speed_multiplier if in_transition else 1.0) * delta, 0.0, 1.0)
	var zoom_lerp: float = clamp(zoom_speed * (focus_zoom_speed_multiplier if in_transition else 1.0) * delta, 0.0, 1.0)

	position = position.lerp(target_pos, move_lerp)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_lerp)
	
	_process_shake(delta)

	_advance_focus_state(delta)

	if debug_draw_bounds:
		_debug_last_base_bounds = base_bounds
		_debug_last_focus_bounds = focus_bounds
		_debug_has_focus_bounds = _has_active_interest
		queue_redraw()

func _get_targets() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for path in target_paths:
		var target := get_node_or_null(path)
		if target and target is Node2D:
			result.append(target)
	return result

func queue_point_of_interest(point: Vector2) -> void:
	_interest_queue.append(point)
	_ensure_focus_cycle_started()

func queue_random_point_of_interest(radius: float = debug_random_radius) -> Vector2:
	var point = _create_random_interest_point(radius)
	queue_point_of_interest(point)
	return point

func _ensure_focus_cycle_started() -> void:
	if _focus_state != FocusState.IDLE:
		return
	if _interest_queue.is_empty():
		return
	_active_interest_point = _interest_queue[0]
	_has_active_interest = true
	_focus_state = FocusState.ENTERING
	_focus_timer = 0.0

func _advance_focus_state(delta: float) -> void:
	if _focus_state == FocusState.IDLE:
		return
	_focus_timer += delta
	while true:
		var duration = _get_state_duration(_focus_state)
		if duration > 0.0 and _focus_timer < duration:
			break
		match _focus_state:
			FocusState.ENTERING:
				_focus_state = FocusState.HOLD
				_focus_timer = 0.0
			FocusState.HOLD:
				_focus_state = FocusState.RETURNING
				_focus_timer = 0.0
			FocusState.RETURNING:
				_finish_focus_cycle()
				return
		# Loop continua para cobrir duracoes zero em sequencia
		if _focus_state == FocusState.IDLE:
			return

func _get_focus_blend() -> float:
	if not _has_active_interest:
		return 0.0
	match _focus_state:
		FocusState.ENTERING:
			return 1.0 if focus_enter_duration <= 0.0 else clamp(_focus_timer / max(focus_enter_duration, 0.00001), 0.0, 1.0)
		FocusState.HOLD:
			return 1.0
		FocusState.RETURNING:
			return 0.0 if focus_return_duration <= 0.0 else 1.0 - clamp(_focus_timer / max(focus_return_duration, 0.00001), 0.0, 1.0)
		_:
			return 0.0

func _get_state_duration(state: FocusState) -> float:
	match state:
		FocusState.ENTERING:
			return max(focus_enter_duration, 0.0)
		FocusState.HOLD:
			return max(focus_hold_duration, 0.0)
		FocusState.RETURNING:
			return max(focus_return_duration, 0.0)
		_:
			return 0.0

func _finish_focus_cycle() -> void:
	var completed_point = _active_interest_point
	if not _interest_queue.is_empty():
		_interest_queue.remove_at(0)
	_active_interest_point = Vector2.ZERO
	_focus_state = FocusState.IDLE
	_focus_timer = 0.0
	if _has_active_interest:
		point_of_interest_completed.emit(completed_point)
	_has_active_interest = false
	_ensure_focus_cycle_started()

func _get_bounding_box(targets: Array[Node2D]) -> Rect2:
	var min_pos = Vector2.INF
	var max_pos = -Vector2.INF
	
	for target in targets:
		var pos = _get_target_effective_pos(target)
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	return Rect2(min_pos, max_pos - min_pos)

func _get_target_effective_pos(target: Node2D) -> Vector2:
	return target.global_position

func _calculate_zoom(bounds: Rect2) -> float:
	var screen_size = get_viewport_rect().size
	if screen_size.x == 0 or screen_size.y == 0:
		return 1.0
	
	var candidate_zoom: float = clamp(zoom.x, min_zoom, max_zoom)
	for i in range(2):
		var current_margin = _get_margin_for_zoom(candidate_zoom)
		var required_size = bounds.size + current_margin * 2.0
		var zoom_x = screen_size.x / max(required_size.x, 1.0)
		var zoom_y = screen_size.y / max(required_size.y, 1.0)
		candidate_zoom = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)
	
	return candidate_zoom

func _get_margin_for_zoom(zoom_value: float) -> Vector2:
	if is_zero_approx(max_zoom - min_zoom):
		return margin_min
	var t = clamp(inverse_lerp(min_zoom, max_zoom, zoom_value), 0.0, 1.0)
	return margin_min.lerp(margin_max, t)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Key.KEY_Q:
			queue_random_point_of_interest(debug_random_radius)
			return
		if debug_enable_runtime_input and event.keycode == debug_trigger_key:
			queue_point_of_interest(_create_debug_interest_point())
			return

func _create_debug_interest_point() -> Vector2:
	if debug_use_mouse_position and get_viewport():
		return get_global_mouse_position()
	return _create_random_interest_point(debug_random_radius)

func _create_random_interest_point(radius: float) -> Vector2:
	var direction = Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))
	var distance = _rng.randf_range(0.0, max(radius, 0.0))
	return global_position + direction * distance

func _draw() -> void:
	if not debug_draw_bounds:
		return
	_draw_rect_world(_debug_last_base_bounds, debug_base_bounds_color)
	if _debug_has_focus_bounds:
		_draw_rect_world(_debug_last_focus_bounds, debug_focus_bounds_color)
	if _has_active_interest:
		draw_circle(to_local(_active_interest_point), 12.0, debug_interest_color)

func _draw_rect_world(rect: Rect2, color: Color) -> void:
	var top_left = to_local(rect.position)
	var bottom_right = to_local(rect.position + rect.size)
	draw_rect(Rect2(top_left, bottom_right - top_left), color, false, 2.0)

func shake(strength: float, duration: float = 0.5) -> void:
	_shake_strength = max(_shake_strength, strength)
	# Simple decay approximation based on duration if needed, 
	# but here we just set strength and let process handle decay
	
func _process_shake(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = move_toward(_shake_strength, 0, _shake_decay * delta * 10.0) # Decay faster
		offset = Vector2(
			_rng.randf_range(-_shake_strength, _shake_strength),
			_rng.randf_range(-_shake_strength, _shake_strength)
		)
	else:
		offset = Vector2.ZERO
