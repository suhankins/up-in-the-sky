extends MeshInstance3D

func _ready() -> void:
	self.visible = NavigationServer3D.get_debug_enabled()
