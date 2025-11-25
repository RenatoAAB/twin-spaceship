extends Node
class_name ParticleSpawnerComponent

@export var hit_particles: PackedScene
@export var destroy_particles: PackedScene
@export var trail_particles: PackedScene

func spawn_hit(position: Vector2, normal: Vector2 = Vector2.ZERO) -> void:
	_spawn(hit_particles, position, normal.angle())

func spawn_destroy(position: Vector2) -> void:
	_spawn(destroy_particles, position, 0.0)

func _spawn(scene: PackedScene, position: Vector2, rotation: float) -> void:
	if not scene:
		return
		
	var instance = scene.instantiate()
	instance.global_position = position
	instance.rotation = rotation
	
	# Adiciona à raiz da cena atual para que não seja deletado com o pai
	get_tree().current_scene.add_child(instance)
	
	if instance is CPUParticles2D or instance is GPUParticles2D:
		instance.emitting = true
		# Opcional: deletar após emissão se o script da partícula não fizer isso
