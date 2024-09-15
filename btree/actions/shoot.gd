class_name Shoot extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	return actor.shoot()
