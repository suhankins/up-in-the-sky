class_name LookAround extends ActionLeaf

var timer: SceneTreeTimer

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if not timer:
		timer = get_tree().create_timer(4.0)
		actor.animation_tree.set('parameters/look_around/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		return RUNNING
	if timer.time_left > 0:
		return RUNNING
	timer = null
	return SUCCESS

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	timer = null
	actor.animation_tree.set('parameters/look_around/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)