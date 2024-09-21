class_name IsTargetDuckCover extends ConditionLeaf


func tick(actor: Node, _blackboard) -> int:
	if not actor.target:
		return FAILURE
	if actor.target.is_in_group("duck_cover"):
		return SUCCESS
	return FAILURE
