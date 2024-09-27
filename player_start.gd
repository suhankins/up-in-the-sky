extends Node3D

@onready var player: Player = get_tree().get_nodes_in_group('player')[0]


func _ready() -> void:
	player.global_position = self.global_position
