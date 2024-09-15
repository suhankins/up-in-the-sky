class_name SetMoveTargetToNextPatrolPoint extends ActionLeaf


func tick(actor: Node, _blackboard) -> int:
	var next_control_point = actor.get_next_patrol_point()
	if next_control_point:
		actor.set_move_target(next_control_point)
		return SUCCESS
	return FAILURE
