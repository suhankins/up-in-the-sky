class_name WasJustShot extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.was_just_shot:
		return SUCCESS
	return FAILURE
