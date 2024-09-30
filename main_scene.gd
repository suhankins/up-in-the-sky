extends Node3D

@export var main_menu: PackedScene
@onready var current_scene: Level = self.get_child(0)
@onready var fade_box: FadeBox = $FadeBox
@onready var loading_text: Label = $LoadingText

var packed_current_scene: PackedScene


func _ready() -> void:
	current_scene.change_scene_signal.connect(_change_scene)
	fade_box.fade_out()
	loading_text.hide()


func _restart_scene():
	self._change_scene(self.packed_current_scene)


func _change_scene(scene: PackedScene):
	fade_box.fade_in()
	await fade_box.fade_finished
	loading_text.show()
	current_scene.queue_free()
	var new_scene = scene.instantiate()
	self.add_child(new_scene)
	self.current_scene = new_scene
	self.current_scene.change_scene_signal.connect(_change_scene)
	self.current_scene.restart_signal.connect(_restart_scene)
	self.current_scene.to_main_menu.connect(_to_main_menu)
	self.packed_current_scene = scene
	loading_text.hide()
	fade_box.fade_out()

func _to_main_menu():
	self._change_scene(main_menu)
