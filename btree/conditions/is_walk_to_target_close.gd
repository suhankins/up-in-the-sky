class_name IsWalkToTargetClose extends ConditionLeaf

@export var close_threshold: float = 1.0

func tick(actor: Node, _blackboard) -> int:
	print_debug('distance to target ', actor.navigation_agent.distance_to_target())
	if actor.navigation_agent.distance_to_target() <= close_threshold:
		return SUCCESS
	return FAILURE