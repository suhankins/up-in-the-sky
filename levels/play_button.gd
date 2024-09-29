extends Button

@export var next_scene: PackedScene


func _pressed() -> void:
	get_parent().get_parent().change_scene(next_scene)
