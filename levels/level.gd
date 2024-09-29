class_name Level extends Node3D

signal change_scene_signal(scene: PackedScene)
signal restart_signal


func change_scene(scene: PackedScene):
	print_debug("Change scene called")
	self.change_scene_signal.emit(scene)


func restart():
	self.restart_signal.emit()
