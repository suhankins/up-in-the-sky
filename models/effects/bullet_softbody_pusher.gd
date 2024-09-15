extends Area3D

@onready var despawn_timer: Timer = $DespawnTimer


func _ready() -> void:
	despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	self.queue_free()
