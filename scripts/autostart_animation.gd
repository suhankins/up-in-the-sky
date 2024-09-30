extends AnimationPlayer

@export var animation_name: StringName


func _ready() -> void:
	self.play(animation_name)
