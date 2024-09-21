extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var animation_played: bool = false

func take_damage(_damage: float):
	if not animation_played:
		animation_player.play('break')
		animation_played = true
