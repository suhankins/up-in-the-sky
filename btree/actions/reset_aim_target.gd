class_name ResetAimTarget extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.reset_aim_target()
	return SUCCESS
