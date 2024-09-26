extends Node3D

@export var delete_on_breaking: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var animation_played: bool = false


func take_damage(_damage: float) -> void:
	if not animation_played:
		animation_player.play("break")
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)
		animation_played = true


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "break" and delete_on_breaking:
		self.queue_free()
