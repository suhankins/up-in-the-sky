extends Node3D

@export var next_scene: PackedScene


func _on_interactable_interacted(_player):
	var scene_root = self.get_parent_node_3d()
	if next_scene:
		scene_root.change_scene(next_scene)
	else:
		scene_root.change_to_main_menu()
