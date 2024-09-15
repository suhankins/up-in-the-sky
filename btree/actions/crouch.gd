class_name Crouch extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.should_crouch = true
	return SUCCESS
