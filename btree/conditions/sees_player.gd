extends ConditionLeaf

func tick(actor: Node, _blackboard) -> int:
    if actor.sees_player():
        return SUCCESS
    return FAILURE
