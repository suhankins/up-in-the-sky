class_name MoveToTarget extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.move_target is AIPoint:
		if not actor.move_target.occupy(actor):
			actor.move_target = null
			return FAILURE
	if actor.move_to_target(blackboard.get_value(NPCBlackboard.DELTA)):
		return SUCCESS
	return RUNNING
