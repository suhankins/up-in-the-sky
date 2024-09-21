class_name ResetWasJustShot extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.was_just_shot = false
	return SUCCESS
