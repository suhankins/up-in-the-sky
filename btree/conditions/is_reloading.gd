class_name IsReloading extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_reloading():
		return SUCCESS
	return FAILURE
