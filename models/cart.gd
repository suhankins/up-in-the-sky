class_name Cart extends RigidBody3D

@export var covers: Array[Cover]
@export var regions: Array[NavigationRegion3D]
@onready var region_rids: Array = self.regions.map(
	func(region: NavigationRegion3D): return region.get_rid()
)
var moved = false
var moved_by_player = false
const STOPPED_THRESHOLD = 0.0002
@export var cover_enabled_by_default: bool = false
@onready var rolling_player: AudioStreamPlayer3D = $RollingAudio
@onready var hit_player: AudioStreamPlayer3D = $HitAudio


func _is_moving() -> bool:
	return (
		not VectorHelper.every_component_abs_is_less_than(self.linear_velocity, STOPPED_THRESHOLD)
		or not VectorHelper.every_component_abs_is_less_than(
			self.angular_velocity, STOPPED_THRESHOLD
		)
	)


func _ready() -> void:
	assert(regions.size() != 0, 'No regions assigned to cart')
	if cover_enabled_by_default:
		self.enable_cover()


func enable_cover():
	for cover in covers:
		cover.enabled = true


func _physics_process(_delta: float) -> void:
	if _is_moving():
		if linear_velocity.length_squared() > 0.5 and not self.rolling_player.playing:
			self.rolling_player.playing = true
		self.moved = true
		return
	if self.moved:
		print_debug("region rebake called")
		moved = false
		moved_by_player = false
		var closest_navigation_point: Vector3 = NavigationServer3D.map_get_closest_point(
			get_world_3d().navigation_map, global_position
		)
		var navigation_region_rid: RID = NavigationServer3D.map_get_closest_point_owner(
			get_world_3d().navigation_map, closest_navigation_point
		)
		var region_index: int = self.region_rids.find(navigation_region_rid)
		var navigation_region = self.regions[region_index]
		if navigation_region.is_baking():
			await navigation_region.bake_finished
		navigation_region.bake_navigation_mesh()


func _on_interactable_interacted(player: Player) -> void:
	moved_by_player = true
	hit_player.playing = true
	apply_central_impulse(
		VectorHelper.get_direction(player.global_position, self.global_position) * 10,
	)


func _on_body_entered(body: Node) -> void:
	if body is EnemyNPC and moved_by_player:
		body.take_damage(body.health)
