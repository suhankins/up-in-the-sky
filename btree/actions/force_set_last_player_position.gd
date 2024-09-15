class_name ForceSetLastPlayerPosition extends ActionLeaf
## Sets last seen player position even if NPC doesn't see the player.
## Normally shouldn't be used, as [SeesPlayer] condition sets last player position.


func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value(NPCBlackboard.LAST_PLAYER_POSITION, actor.player.global_position)
	return SUCCESS
