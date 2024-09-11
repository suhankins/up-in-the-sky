extends Sprite3D

func _ready() -> void:
	self.visible = NavigationServer3D.get_debug_enabled()
