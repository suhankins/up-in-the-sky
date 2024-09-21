extends Node3D
class_name Cover

@onready var raycast: RayCast3D = $RayCast3D

@export var requires_crouching: bool = false
@export var unsafe_distance: float = 1.5
@export var safe_angle: float = -0.8
@export var enabled: bool = true

## Max distance between position and closest navmesh point
@export var outside_threshold: float = 0.05


func _is_on_navmesh() -> bool:
	var closest_point = NavigationServer3D.map_get_closest_point(
		get_world_3d().navigation_map, global_position
	)
	if (
		VectorHelper.get_with_y(closest_point).distance_to(VectorHelper.get_with_y(global_position))
		< outside_threshold
	):
		return true
	return false


func _ready() -> void:
	raycast.enabled = false
	await get_tree().process_frame
	if self.enabled and not _is_on_navmesh():
		print_debug("Outside of navmesh, deleting ", self.global_position)
		self.queue_free()


func is_safe_from_vector(vector: Vector3) -> bool:
	if vector == null:
		return true
	if requires_crouching and vector.distance_to(self.global_position) < unsafe_distance:
		return false
	var cover_to_player_direction = VectorHelper.get_with_y(self.global_position).direction_to(
		VectorHelper.get_with_y(vector)
	)
	var direction = Vector3(sin(self.global_rotation.y), 0, cos(self.global_rotation.y))
	var dot_product = cover_to_player_direction.dot(direction)
	if dot_product > safe_angle:
		return false
	return not VisionHelper.sees_player_at_vector(raycast, VectorHelper.get_with_y(vector, 0.5))
