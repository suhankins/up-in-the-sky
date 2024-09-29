extends Area3D

@export var object_to_fade: Node3D


func _ready() -> void:
	object_to_fade.visible = self.has_overlapping_bodies()


func _on_body_exited(_body: Node3D) -> void:
	# When player crouches, technically for a frame they disappear
	await get_tree().physics_frame
	await get_tree().physics_frame
	object_to_fade.visible = self.has_overlapping_bodies()


func _on_body_entered(_body: Node3D) -> void:
	object_to_fade.show()
