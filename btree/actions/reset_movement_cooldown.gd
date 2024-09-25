class_name ResetMovementCooldown extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.stop_movement_cooldown()
	return SUCCESS
