extends Label

@export var player: Player

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.health)
	
func _on_player_health_changed(current_health: float):
	self.text = "Health: %s" % current_health
