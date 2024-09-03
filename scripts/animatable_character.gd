extends CharacterBody3D
class_name AnimatableCharacter

@export var animation_tree: AnimationTree
@export var crouch_speed: float
@export var walk_speed: float

func is_crouching() -> bool:
	push_error('Not implemented')
	return false

func play_reload_animation():
	animation_tree.set('parameters/reload/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func play_fire_animation():
	animation_tree.set('parameters/fire_gun/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func animate_legs():
	var velocity_angle = velocity.signed_angle_to(Vector3(0, 0, -1), Vector3(0, -1, 0))
	var difference = velocity_angle - rotation.y
	var movement_speed_ratio = velocity.length() / (crouch_speed if is_crouching() else walk_speed)
	var leg_vector = Vector2(sin(difference), cos(difference)) * movement_speed_ratio

	animation_tree.set('parameters/walk_blend_space/blend_position', leg_vector)
	animation_tree.set('parameters/crouch_blend_space/blend_position', leg_vector)
	animation_tree.set("parameters/Transition/transition_request", 'crouching' if is_crouching() else 'standing')
