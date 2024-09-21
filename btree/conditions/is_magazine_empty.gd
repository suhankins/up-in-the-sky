class_name IsMagazineEmpty extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.weapon.is_magazine_empty():
		return SUCCESS
	return FAILURE
