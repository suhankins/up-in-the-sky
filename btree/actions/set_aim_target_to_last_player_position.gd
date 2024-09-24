class_name SetAimTargetToLastPlayerPosition extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION, null, actor.team) == null:
		return FAILURE
	actor.set_aim_target_position(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION, null, actor.team))
	return SUCCESS
