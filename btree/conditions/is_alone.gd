class_name IsAlone extends ConditionLeaf


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(NPCBlackboard.LIST_OF_NPCS).size() <= 1:
		return SUCCESS
	return FAILURE
