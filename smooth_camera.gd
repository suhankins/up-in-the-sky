extends Node3D

@export var targets: Array[Node3D]


func get_center() -> Vector3:
	var summed_vector = Vector3()
	for target in targets:
		summed_vector += target.position
	return summed_vector / targets.size()


func _ready() -> void:
	position = get_center()


func _process(_delta: float) -> void:
	position = lerp(position, get_center(), 0.5)
