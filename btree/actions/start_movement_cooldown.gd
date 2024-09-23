class_name StartMovementCooldown extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.start_movement_cooldown()
	return SUCCESS
