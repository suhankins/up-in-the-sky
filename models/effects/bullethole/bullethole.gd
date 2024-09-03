extends MeshInstance3D

func _ready() -> void:
	self.transform = self.transform.rotated_local(Vector3(0, 0, -1), randf_range(-PI, PI))