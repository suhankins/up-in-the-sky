extends Button

@export var control_to_show: Control


func _pressed() -> void:
	control_to_show.visible = not control_to_show.visible

