class_name SetAlert extends ActionLeaf

@export var alerted_state: bool = false


func tick(_actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value(NPCBlackboard.ALERTED, alerted_state)
	return SUCCESS
