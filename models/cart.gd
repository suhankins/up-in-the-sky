class_name Cart extends RigidBody3D

@export var covers: Array[Cover]
@export var navigation_region: NavigationRegion3D
var moved = false
var moved_by_player = false
const STOPPED_THRESHOLD = 0.0002
@export var cover_enabled_by_default: bool = false
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _is_moving() -> bool:
	return (
		not VectorHelper.every_component_abs_is_less_than(self.linear_velocity, STOPPED_THRESHOLD)
		or not VectorHelper.every_component_abs_is_less_than(
			self.angular_velocity, STOPPED_THRESHOLD
		)
	)


func _ready() -> void:
	if cover_enabled_by_default:
		self.enable_cover()


func enable_cover():
	for cover in covers:
		cover.enabled = true


func _physics_process(_delta: float) -> void:
	if _is_moving():
		if linear_velocity.length_squared() > 0.5 and not self.audio_player.playing:
			self.audio_player.playing = true
		self.moved = true
		return
	if self.moved:
		print_debug("region rebake called")
		navigation_region.bake_navigation_mesh()
		moved = false
		moved_by_player = false


func _on_interactable_interacted(player: Player) -> void:
	moved_by_player = true
	apply_central_impulse(
		VectorHelper.get_direction(player.global_position, self.global_position) * 10,
	)


func _on_body_entered(body: Node) -> void:
	if body is EnemyNPC and _is_moving() and moved_by_player:
		body.take_damage(body.health)
