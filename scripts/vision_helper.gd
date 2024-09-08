class_name VisionHelper

static func sees_danger(raycast: RayCast3D, danger_position: Vector3) -> bool:
	raycast.target_position = raycast.to_local(danger_position)
	raycast.force_raycast_update()
	var collider: CollisionObject3D = raycast.get_collider()
	if collider == null:
		return false
	return collider.is_in_group('danger_to_npc')

static func sees_player(raycast: RayCast3D, player: Player) -> bool:
	var target = player.crouching_raycast_origin.global_position if player.is_crouching() else player.standing_raycast_origin.global_position
	raycast.target_position = raycast.to_local(target)
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider == null:
		return false
	return collider.is_in_group('player')
