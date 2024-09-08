extends Label

@export var player: Player

func _ready() -> void:
	player.weapon.ammo_changed.connect(_on_player_weapon_ammo_changed)
	_on_player_weapon_ammo_changed(player.weapon.current_ammo, player.weapon.max_ammo)
	
func _on_player_weapon_ammo_changed(current_ammo: int, max_ammo: int):
	self.text = "Ammo: %s/%s" % [current_ammo, max_ammo]
