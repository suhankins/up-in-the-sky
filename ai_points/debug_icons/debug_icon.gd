extends Sprite3D

func _ready() -> void:
	if not NavigationServer3D.get_debug_enabled():
		self.queue_free()
