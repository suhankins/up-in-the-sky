class_name KnowsLastPlayerPosition extends ConditionLeaf

@export var close_threshold: float = 1.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION, null, actor.team):
		return SUCCESS
	return FAILURE
