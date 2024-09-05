class_name InDuckCover extends ConditionLeaf

func tick(actor: Node, _blackboard) -> int:
	var cover: Cover = actor.get_current_cover()
	if not cover:
		return FAILURE
	return SUCCESS if cover.requires_crouching else FAILURE
