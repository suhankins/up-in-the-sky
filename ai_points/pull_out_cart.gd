class_name PullOutCartPoint extends Node3D

@export var cart: RigidBody3D
@export var distance_threshold_squared: float = 0.1
@export var viable_npc_distance: float = 2.0
@onready var destination: Node3D = $Target
var enabled = true


## Returns whether is cart at position
func move_cart() -> bool:
	if (
		cart.global_position.distance_squared_to(destination.global_position)
		< distance_threshold_squared
	):
		cart.enable_cover()
		return true
	print_debug(VectorHelper.get_direction(cart.global_position, destination.global_position))
	cart.apply_central_force(
		VectorHelper.get_direction(cart.global_position, destination.global_position) * 50
	)
	return false
