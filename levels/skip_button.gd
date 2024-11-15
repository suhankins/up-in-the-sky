extends Button

@export var current_level_root: Level
@export var next_level: PackedScene

func _on_pressed() -> void:
	current_level_root.change_scene(next_level)
