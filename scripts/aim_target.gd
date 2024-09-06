class_name AimTarget extends Resource

var target_position: Vector3
var target_player: Player

static func aim_target_from_vector(vector: Vector3) -> AimTarget:
	var new_aim_target = AimTarget.new()
	new_aim_target.target_position = vector
	return new_aim_target

static func aim_target_from_player(player: Player) -> AimTarget:
	var new_aim_target = AimTarget.new()
	new_aim_target.target_player = player
	return new_aim_target

func get_position_to_shoot_at() -> Vector3:
	if target_position:
		return target_position
	if target_player:
		if target_player.is_crouching():
			return target_player.crouching_raycast_origin.global_position 
		else:
			return target_player.standing_raycast_origin.global_position
	return Vector3.ZERO

func get_spread_modifier() -> float:
	var modifier = 1.0
	if target_player and target_player.is_crouching():
		modifier *= 1.2
	return modifier
