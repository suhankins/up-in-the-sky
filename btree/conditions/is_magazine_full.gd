class_name IsMagazineFull extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.weapon.is_magazine_full():
		return SUCCESS
	return FAILURE
