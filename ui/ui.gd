extends Control

@export var player: Player

@onready var health_control: HealthUI = $HealthControl
@onready var ammo_control: AmmoUI = $AmmoControl


func _ready() -> void:
	if not player:
		push_error("No player assinged to UI!")
	health_control.assign_player(player)
	ammo_control.assign_player(player)
