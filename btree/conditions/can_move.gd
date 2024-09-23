class_name CanMove extends ConditionLeaf


func tick(actor: Node, _blackboard) -> int:
	if actor.can_move():
		return SUCCESS
	return FAILURE
