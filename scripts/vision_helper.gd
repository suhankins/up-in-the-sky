class_name VisionHelper

static func sees_player_at_vector(raycast: RayCast3D, vector: Vector3) -> bool:
	raycast.target_position = raycast.to_local(vector)
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider == null:
		return false
	return collider.is_in_group("player")


static func sees_player(raycast: RayCast3D, player: Player) -> bool:
	var target = (
		player.crouching_raycast_origin.global_position
		if player.is_crouching()
		else player.standing_raycast_origin.global_position
	)
	return VisionHelper.sees_player_at_vector(raycast, target)
