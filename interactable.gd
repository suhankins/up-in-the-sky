class_name Interactable extends Node3D

signal interacted(player: Player)

## Make sure collision only checks for player
@export var collision: Area3D
@onready var prompt: Node3D = $Prompt


func _process(_delta: float) -> void:
	if not collision.has_overlapping_bodies():
		prompt.visible = false
		return
	prompt.visible = true
	if Input.is_action_just_pressed("interact"):
		interacted.emit(collision.get_overlapping_bodies()[0])
