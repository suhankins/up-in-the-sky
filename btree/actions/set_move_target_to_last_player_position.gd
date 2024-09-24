class_name SetMoveTargetToLastPlayerPosition extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.set_move_target_position(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION, null, actor.team))
	return SUCCESS
