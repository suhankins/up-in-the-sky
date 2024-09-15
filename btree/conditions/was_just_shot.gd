class_name WasJustShot extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	print_debug('was just shot ', actor.was_just_shot)
	if actor.was_just_shot:
		return SUCCESS
	return FAILURE
