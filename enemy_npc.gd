extends AnimatableCharacter
class_name EnemyNPC

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var player: Player = get_tree().get_nodes_in_group('player')[0]
@onready var cover_detection: Area3D = $CoverDetection

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision

@export var should_crouch: bool = false
## Reference to current navigation target
@export var target: Node3D = null

func _ready() -> void:
	navigation_agent.target_desired_distance = 0.05

func sort_by_distance(a: Node3D, b: Node3D) -> bool:
	return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)

func find_closest_safe_cover() -> Cover:
	var covers = get_tree().get_nodes_in_group('cover')
	covers.sort_custom(sort_by_distance)
	for cover: Cover in covers:
		if cover.is_safe_from_player():
			return cover
	return null

func get_current_cover() -> Cover:
	if not cover_detection.has_overlapping_areas():
		return null
	return cover_detection.get_overlapping_areas()[0].get_parent()

func is_current_cover_safe() -> bool:
	var current_cover = get_current_cover()
	if not current_cover:
		return false
	return current_cover.is_safe_from_player()

func _process(_delta: float) -> void:
	update_collision()

func _physics_process(_delta: float) -> void:
	animate_legs()

func update_collision() -> void:
	standing_collision.disabled = is_crouching()
	crouching_collision.disabled = not is_crouching()

func move_to_target(delta: float) -> bool:
	if self.navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return true
	var destination = self.navigation_agent.get_next_path_position()
	var local_destination = self.to_local(destination)
	var distance = local_destination.length()
	if distance < get_speed() * delta:
		velocity = local_destination / delta
		self.global_position = destination
	else:
		velocity = local_destination.normalized() * get_speed()
		self.global_position += local_destination.normalized() * get_speed() * delta
	return false

func get_speed():
	return self.crouch_speed if is_crouching() else self.walk_speed

func set_target(new_target: Node3D):
	navigation_agent.target_position = new_target.global_position
	self.target = new_target

func sees_player() -> bool:
	return VisionHelper.sees_player(vision_raycast, player)

func is_crouching() -> bool:
	return should_crouch
