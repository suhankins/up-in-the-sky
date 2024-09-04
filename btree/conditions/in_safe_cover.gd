extends ConditionLeaf

func tick(actor: Node, _blackboard) -> int:
    if actor.is_current_cover_safe():
        return SUCCESS
    return FAILURE
