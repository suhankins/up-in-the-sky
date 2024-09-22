class_name IsCloseToCartPullPoint extends ConditionLeaf


func tick(actor: Node, _blackboard) -> int:
	var triggers = get_tree().get_nodes_in_group('pull_out_cart_points')
	if triggers.size() == 0:
		return FAILURE
	for trigger in triggers:
		if not trigger.enabled:
			continue
		if trigger.global_position.distance_squared_to(actor.global_position) < 3.0:
			return SUCCESS
	return FAILURE
