class_name InCover extends ConditionLeaf


func tick(actor: Node, _blackboard) -> int:
	if actor.get_current_cover():
		return SUCCESS
	return FAILURE
