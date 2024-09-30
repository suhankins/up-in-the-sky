class_name Level extends Node3D

signal change_scene_signal(scene: PackedScene)
signal restart_signal
signal to_main_menu


func change_scene(scene: PackedScene):
	print_debug("Change scene called")
	self.change_scene_signal.emit(scene)


func restart():
	self.restart_signal.emit()


func change_to_main_menu():
	self.to_main_menu.emit()
