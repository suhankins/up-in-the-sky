extends Resource
class_name Weapon

signal ammo_changed(current_ammo, max_ammo)

## Shots per second
@export var rate_of_fire: float = 4.0
## Spread in radians
@export var spread = 0.05
@export var bullet_distance = 20.0
@export var reload_time: float = 1.0
@export var max_ammo: int = 7
@export var current_ammo: int = 7
@export var damage: float = 1.0
@export var tracer_scene: PackedScene
@export var bullethole_scene: PackedScene

func is_magazine_full() -> bool:
	return max_ammo == current_ammo

func refill_magazine() -> void:
	current_ammo = max_ammo
	ammo_changed.emit(current_ammo, max_ammo)

func spend_bullet() -> bool:
	if current_ammo > 0:
		current_ammo -= 1
		ammo_changed.emit(current_ammo, max_ammo)
		return true
	return false

func apply_spread_to_target(target_position: Vector3, spread_modifier: float = 1.0) -> Vector3:
	var modified_spread = self.spread * spread_modifier
	return target_position.rotated(Vector3(1, 0, 0), randf_range(-modified_spread, modified_spread)).rotated(Vector3(0, 1, 0), randf_range(-modified_spread, modified_spread))

func spawn_tracer(barrel_end: Node3D, to: Vector3 = Vector3.ZERO) -> void:
	var tracer: Node3D = tracer_scene.instantiate()
	barrel_end.add_child(tracer)
	tracer.global_transform = barrel_end.global_transform
	if to != Vector3.ZERO:
		tracer.look_at(to)
		var length = tracer.global_position.distance_to(to)
		tracer.scale.z = length
	else:
		tracer.scale.z = bullet_distance

func spawn_bullethole(collided_with: Node, collision_position: Vector3, collision_normal: Vector3) -> void:
	var bullethole_instance = bullethole_scene.instantiate()
	collided_with.add_child(bullethole_instance)
	bullethole_instance.global_position = collision_position
	bullethole_instance.look_at(collision_position + collision_normal, Vector3.UP)
