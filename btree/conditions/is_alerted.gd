class_name IsAlerted extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(NPCBlackboard.ALERTED, false, actor.team):
		return SUCCESS
	return FAILURE
