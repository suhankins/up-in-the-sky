extends AnimatableCharacter
class_name EnemyNPC

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var player: Player = get_tree().get_nodes_in_group('player')[0]
@onready var cover_detection: Area3D = $CoverDetection

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
	# We can't be in cover if we are navigating somewhere
	if not navigation_agent.is_navigation_finished():
		return null
	if not cover_detection.has_overlapping_areas():
		return null
	return cover_detection.get_overlapping_areas()[0].get_parent()

func is_current_cover_safe() -> bool:
	var current_cover = get_current_cover()
	if not current_cover:
		return false
	return current_cover.is_safe_from_player()

func _process(_delta: float) -> void:
	if not is_current_cover_safe() and VisionHelper.sees_player(vision_raycast, player):
		var closest_safe_cover = find_closest_safe_cover()
		if closest_safe_cover:
			navigation_agent.target_position = closest_safe_cover.global_position

func _physics_process(delta: float) -> void:
	var destination = navigation_agent.get_next_path_position()
	var local_destination = to_local(destination)
	var distance = local_destination.length()
	if distance < walk_speed * delta:
		velocity = local_destination / delta
		global_position = destination
	else:
		velocity = local_destination.normalized() * walk_speed
		global_position += local_destination.normalized() * walk_speed * delta
	animate_legs()

func is_crouching():
	var current_cover = get_current_cover()
	if not current_cover:
		return false
	return current_cover.requires_crouching
