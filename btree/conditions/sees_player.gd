class_name SeesPlayer extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.sees_player():
		return SUCCESS
	return FAILURE
