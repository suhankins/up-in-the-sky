class_name SetMoveTargetToClosestSafeCover extends ActionLeaf


func tick(actor: Node, _blackboard) -> int:
	var closest_safe_cover = actor.find_closest_safe_cover()
	if closest_safe_cover:
		if not closest_safe_cover.occupy(actor):
			return FAILURE
		actor.set_move_target(closest_safe_cover)
		return SUCCESS
	return FAILURE
