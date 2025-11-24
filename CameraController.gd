extends Camera2D

@export var target_paths: Array[NodePath]
@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.5
@export var margin_min: Vector2 = Vector2(150, 150)
@export var margin_max: Vector2 = Vector2(400, 400)
@export var zoom_speed: float = 2.0
@export var move_speed: float = 5.0

func _process(delta: float) -> void:
	var targets := _get_targets()
	if targets.is_empty():
		return
		
	var bounds = _get_bounding_box(targets)
	var target_pos = bounds.get_center()
	var target_zoom = _calculate_zoom(bounds)

	var move_lerp: float = clamp(move_speed * delta, 0.0, 1.0)
	var zoom_lerp: float = clamp(zoom_speed * delta, 0.0, 1.0)
	position = position.lerp(target_pos, move_lerp)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_lerp)

func _get_targets() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for path in target_paths:
		var target := get_node_or_null(path)
		if target and target is Node2D:
			result.append(target)
	return result

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
