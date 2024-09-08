extends CharacterBody3D
class_name AnimatableCharacter

@export var animation_tree: AnimationTree

func is_crouching() -> bool:
	push_error('Not implemented')
	return false

func play_reload_animation():
	animation_tree.set('parameters/reload/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func play_fire_animation():
	animation_tree.set('parameters/fire_gun/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func get_speed() -> float:
	push_error('Not implemented!')
	return 0

func animate_legs():
	var velocity_angle = VectorHelper.vector_angle(velocity)
	var difference = velocity_angle - rotation.y
	var speed = self.get_speed()
	if speed == 0.0:
		push_error('Speed is 0.0! This will cause division by 0')
	var movement_speed_ratio = velocity.length() / speed
	var leg_vector = Vector2(sin(difference), cos(difference)) * movement_speed_ratio

	animation_tree.set('parameters/walk_blend_space/blend_position', leg_vector)
	animation_tree.set('parameters/crouch_blend_space/blend_position', leg_vector)
	animation_tree.set("parameters/Transition/transition_request", 'crouching' if is_crouching() else 'standing')
