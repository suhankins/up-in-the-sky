class_name StandUp extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.should_crouch = false
	return SUCCESS
