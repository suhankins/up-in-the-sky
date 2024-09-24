class_name IsAlone extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(NPCBlackboard.LIST_OF_NPCS, [], actor.team).size() <= 1:
		return SUCCESS
	return FAILURE
