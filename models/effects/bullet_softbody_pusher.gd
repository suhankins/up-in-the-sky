extends Area3D

@onready var despawn_timer: Timer = $DespawnTimer


func _ready() -> void:
	despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	# Causes Error: _queue_monitor_update: Parameter "get_space()" is null
	# Bug with the 4.3 engine version https://github.com/godotengine/godot/issues/97116
	self.queue_free()
