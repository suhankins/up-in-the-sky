class_name InCover extends ConditionLeaf

func tick(actor: Node, _blackboard) -> int:
    print_debug(not not actor.get_current_cover())
    if actor.get_current_cover():
        return SUCCESS
    return FAILURE
