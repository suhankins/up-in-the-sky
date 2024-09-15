class_name ResetLastPlayerPosition extends ActionLeaf


func tick(_actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("set_last_player_position", null)
	return SUCCESS
