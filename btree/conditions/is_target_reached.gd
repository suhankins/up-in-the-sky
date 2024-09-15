class_name IsTargetReached extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_target_reached():
		return SUCCESS
	return FAILURE
