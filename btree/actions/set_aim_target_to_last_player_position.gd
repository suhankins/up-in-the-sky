class_name SetAimTargetToLastPlayerPosition extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.set_aim_target_position(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION))
	return SUCCESS
