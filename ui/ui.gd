extends Control

@export var player: Player

@onready var health_control: HealthUI = $HealthControl
@onready var ammo_control: AmmoUI = $AmmoControl


func _ready() -> void:
	if not player:
		push_error("No player assinged to UI!")
	player.ready.connect(_on_player_ready)


func _on_player_ready() -> void:
	health_control.assign_player(player)
	ammo_control.assign_player(player)
