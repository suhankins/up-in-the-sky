class_name SeesPlayer extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.sees_player():
		blackboard.set_value(NPCBlackboard.LAST_PLAYER_POSITION, actor.player.global_position)
		return SUCCESS
	return FAILURE
