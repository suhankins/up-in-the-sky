class_name SetAimTargetToPlayer extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.set_aim_target_to_player()
	return SUCCESS
