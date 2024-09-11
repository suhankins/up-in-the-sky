class_name HealthUI extends Control

@export var player: Player

@onready var health_bar_foreground: TextureRect = $HealthForeground


func assign_player(new_player: Player) -> void:
	self.player = new_player
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.health, player.max_health)


func _on_player_health_changed(current_health: float, max_health: float):
	health_bar_foreground.material.set_shader_parameter("health", current_health / max_health)
