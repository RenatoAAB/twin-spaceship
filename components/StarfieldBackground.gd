extends ColorRect

func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	if cam:
		material.set_shader_parameter("camera_position", cam.global_position)
		
	# Update resolution in case window resizes
	material.set_shader_parameter("resolution", get_viewport_rect().size)
