class_name PullCart extends ActionLeaf


func tick(actor: Node, _blackboard) -> int:
	if not is_instance_valid(actor.move_target):
		actor.move_target = null
		return FAILURE
	if not actor.move_target or not (actor.move_target is PullOutCartPoint):
		return FAILURE
	if not actor.move_target.occupy(actor):
		actor.move_target = null
		return FAILURE
	actor.set_aim_target_node(actor.move_target.cart)
	if actor.move_target.move_cart():
		actor.move_target.queue_free()
		actor.move_target = null
		return SUCCESS
	return RUNNING
