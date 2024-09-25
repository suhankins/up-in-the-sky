class_name SetMoveTargetToClosestViableFlank extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var closest_flank_tuple = actor.find_closest_viable_flank()
	if not closest_flank_tuple.node:
		return FAILURE
	if not closest_flank_tuple.node.occupy(actor):
		return FAILURE
	actor.set_move_target(closest_flank_tuple.node)
	return SUCCESS
