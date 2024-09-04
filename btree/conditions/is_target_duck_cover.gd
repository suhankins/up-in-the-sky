class_name IsTargetDuckCover extends ConditionLeaf

func tick(actor: Node, _blackboard) -> int:
    if not actor.target:
        return FAILURE
    print_debug('target in group ', actor.target.is_in_group('duck_cover'))
    if actor.target.is_in_group('duck_cover'):
        return SUCCESS
    return FAILURE
