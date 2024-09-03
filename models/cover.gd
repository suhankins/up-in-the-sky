extends Node3D
class_name Cover

@onready var raycast: RayCast3D = $RayCast3D

func _ready() -> void:
	raycast.enabled = false
	raycast.target_position = Vector3(0, -1, 0)
	raycast.force_raycast_update()
	if not raycast.get_collider():
		self.queue_free()

func safe_from_player():
	var players = get_tree().get_nodes_in_group('player')
	if players.size() == 0:
		push_warning('No player present!')
		return true
	var player: Player = players[0]
	raycast.target_position = raycast.to_local(player.standing_raycast_origin.global_position)
	raycast.force_raycast_update()
	var collider: CollisionObject3D = raycast.get_collider()
	if collider == null:
		return true
	return not collider.is_in_group('player')
