class_name IsAlerted extends ConditionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
    if blackboard.get_value(NPCBlackboard.ALERTED):
        return SUCCESS
    return FAILURE
