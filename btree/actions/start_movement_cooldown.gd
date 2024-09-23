class_name StartMovementCooldown extends ActionLeaf

@export var time: float = 2


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.start_movement_cooldown(time)
	return SUCCESS
