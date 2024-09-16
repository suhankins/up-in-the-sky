class_name PlayAnimation extends ActionLeaf

var timer: SceneTreeTimer

@export var animation_name: String
@export var animation_duration: float


func _ready() -> void:
	assert(animation_name != null, "No animation set for PlayAnimation node!")
	assert(animation_duration != null, "No animation duration set for PlayAnimation node!")


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if not timer:
		timer = get_tree().create_timer(animation_duration)
		actor.animation_tree.set(
			"parameters/" + animation_name + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
		return RUNNING
	if timer.time_left > 0:
		return RUNNING
	timer = null
	return SUCCESS


func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	timer = null
	actor.animation_tree.set(
		"parameters/" + animation_name + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	)
