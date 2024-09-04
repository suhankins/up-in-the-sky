extends Node3D

@onready var timer: Timer = $Timer
@onready var material: ShaderMaterial = self.get_child(0).get_active_material(0)

func _ready() -> void:
	material.set_shader_parameter('progress', 0.0)

func _process(_delta: float) -> void:
	var progress = 1.0 - timer.time_left / timer.wait_time
	material.set_shader_parameter('progress', progress)
	if timer.is_stopped():
		self.queue_free()
