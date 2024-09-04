class_name WalkToTarget extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.move_to_target(blackboard.get_value('delta')):
		return SUCCESS
	return RUNNING
