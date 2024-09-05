class_name SetLastPlayerPosition extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	print_debug(actor.player.global_position)
	blackboard.set_value(NPCBlackboard.LAST_PLAYER_POSITION, actor.player.global_position)
	return SUCCESS
