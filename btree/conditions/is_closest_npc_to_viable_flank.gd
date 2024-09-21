class_name IsClosestNpcToViableFlank extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var list_of_npcs: Array = blackboard.get_value(NPCBlackboard.LIST_OF_NPCS)
	if list_of_npcs.size() == 0:
		return FAILURE
	var list_of_npcs_and_distances_to_flanks: Array = list_of_npcs.map(
		func(npc: EnemyNPC): return NumberAndNode3DTuple.new(
			npc.find_closest_viable_flank().number, npc
		)
	)
	list_of_npcs_and_distances_to_flanks.sort_custom(
		func(a: NumberAndNode3DTuple, b: NumberAndNode3DTuple): return a.number < b.number
	)
	if list_of_npcs_and_distances_to_flanks[0].node == actor:
		return SUCCESS
	return FAILURE
