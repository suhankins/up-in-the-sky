extends ActionLeaf

func tick(actor: Node, _blackboard) -> int:
	var closest_safe_cover = actor.find_closest_safe_cover()
	if closest_safe_cover:
		actor.navigation_agent.target_position = closest_safe_cover.global_position
		return SUCCESS
	return FAILURE
