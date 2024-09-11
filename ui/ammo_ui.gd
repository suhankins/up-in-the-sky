class_name AmmoUI extends Control

@export var player: Player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullets: Array[Node] = $Magazine/Bullets.get_children()
@onready var magazine_foreground: TextureRect = $Magazine


func assign_player(new_player: Player) -> void:
	self.player = new_player
	player.weapon.bullet_spent.connect(_on_player_weapon_bullet_spent)
	player.weapon.reload_started.connect(_on_player_weapon_reload_started)


func _on_player_weapon_bullet_spent(current_ammo: int, max_ammo: int):
	animation_player.play("move_bullets_up")
	self._update_bullet_visiblity(current_ammo, max_ammo)


func _on_player_weapon_reload_started():
	animation_player.play("reload")


func _update_bullet_visiblity(current_ammo: int = 0, max_ammo: int = 0):
	magazine_foreground.material.set_shader_parameter("ammo", float(current_ammo) / float(max_ammo))
	var bullets_to_hide = max_ammo - current_ammo
	for index in bullets.size():
		bullets[index].visible = index >= bullets_to_hide


func make_all_bullets_visible():
	self._update_bullet_visiblity()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "move_bullets_up":
		animation_player.play("RESET")
