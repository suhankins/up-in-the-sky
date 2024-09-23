class_name Cart extends RigidBody3D

@export var covers: Array[Cover]
@export var navigation_region: NavigationRegion3D
var moved = false
const STOPPED_THRESHOLD = 0.0002


func enable_cover():
	for cover in covers:
		cover.enabled = true


func _physics_process(_delta: float) -> void:
	if (
		not VectorHelper.every_component_abs_is_less_than(self.linear_velocity, STOPPED_THRESHOLD)
		or not VectorHelper.every_component_abs_is_less_than(
			self.angular_velocity, STOPPED_THRESHOLD
		)
	):
		self.moved = true
		return
	if self.moved:
		print_debug("region rebake called")
		navigation_region.bake_navigation_mesh()
		moved = false
