extends Node3D

@export var flank_area: Node3D

func _ready() -> void:
	if not flank_area:
		push_error("No flank area assigned!")


func is_valid_flank_for_player_position(vector: Vector3):
	if vector == null:
		return false
	return (
		vector.x > flank_area.global_position.x - flank_area.scale.x / 2.0
		and vector.x < flank_area.global_position.x + flank_area.scale.x / 2.0
		and vector.z > flank_area.global_position.z - flank_area.scale.z / 2.0
		and vector.z < flank_area.global_position.z + flank_area.scale.z / 2.0
	)
