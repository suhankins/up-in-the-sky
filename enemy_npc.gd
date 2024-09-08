extends AnimatableCharacter
class_name EnemyNPC

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var player: Player = get_tree().get_nodes_in_group('player')[0]
@onready var cover_detection: Area3D = $CoverDetection

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision

@onready var fire_cooldown: Timer = $FireCooldown
@onready var reload_cooldown: Timer = $ReloadCooldown

@onready var animation_timer: Timer = $AnimationTimer
var animation_is_done = false

@onready var behavior_tree: BeehaveTree = $BeehaveTree

@export var crouch_speed: float = 0.75
@export var walk_speed: float = 1.5
@export var patrol_speed: float = 1.0

var should_crouch: bool = false
## Reference to current navigation move_target
var move_target: Node3D = null

var aim_target: AimTarget = null

@export var weapon: Weapon
@export var barrel_end: Node3D

@export var health: float = 3

@export var patrol_points: Array[Node3D] = []

@export var blackboard: NPCBlackboard

func _ready() -> void:
	navigation_agent.target_desired_distance = 0.05
	if not blackboard:
		push_error("No blackboard set!")
	behavior_tree.blackboard = blackboard

func get_sort_by_distance(to: Vector3 = self.global_position):
	return func sort_by_distance(a: Node3D, b: Node3D):
		return a.global_position.distance_to(to) < b.global_position.distance_to(to)

func find_closest_patrol_point() -> Node3D:
	if patrol_points.size() == 0:
		return null
	var sorted_patrol_points = patrol_points.duplicate()
	sorted_patrol_points.sort_custom(get_sort_by_distance())
	return sorted_patrol_points[0]

func get_next_patrol_point() -> Node3D:
	if patrol_points.size() == 0:
		return null
	var current_point = find_closest_patrol_point()
	var index = patrol_points.find(current_point)
	if index >= patrol_points.size() - 1:
		return patrol_points[0]
	return patrol_points[index + 1]

func find_closest_safe_cover() -> Cover:
	var covers = get_tree().get_nodes_in_group('cover')
	covers.sort_custom(get_sort_by_distance())
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
	update_rotation()

func _physics_process(_delta: float) -> void:
	animate_legs()
	update_animation_alert_state()

func update_animation_alert_state():
	animation_tree.set("parameters/alert_state/transition_request", 'alert' if blackboard.get_value(NPCBlackboard.ALERTED) else 'patrol')

func update_rotation():
	if aim_target:
		self.look_at(VectorHelper.get_with_y(aim_target.get_position_to_shoot_at(), self.global_position.y))
		return
	if velocity.length_squared() > 0.0:
		self.rotation.y = VectorHelper.vector_angle(velocity)

func update_collision() -> void:
	standing_collision.disabled = is_crouching()
	crouching_collision.disabled = not is_crouching()

func is_target_reached() -> bool:
	return self.navigation_agent.is_navigation_finished()

func move_to_target(delta: float) -> bool:
	if self.navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return true
	var destination = self.navigation_agent.get_next_path_position()
	var distance = global_position.distance_to(destination)
	if distance < get_speed() * delta:
		self.global_position = destination
	else:
		var direction = VectorHelper.get_with_y(destination - global_position).normalized()
		velocity = direction * get_speed()
		self.global_position += direction * get_speed() * delta
	return false

func get_speed() -> float:
	if is_crouching():
		return self.crouch_speed
	if not blackboard.get_value(NPCBlackboard.ALERTED):
		return self.patrol_speed
	return self.walk_speed

func set_move_target(new_target: Node3D) -> void:
	set_move_target_position(new_target.global_position)
	self.move_target = new_target

func set_move_target_position(target_position: Vector3) -> void:
	navigation_agent.target_position = target_position

func set_aim_target_position(vector: Vector3) -> void:
	self.aim_target = AimTarget.aim_target_from_vector(vector)

func set_aim_target_to_player() -> void:
	self.aim_target = AimTarget.aim_target_from_player(player)

func reset_aim_target() -> void:
	self.aim_target = null

func reload() -> int:
	if self.reload_cooldown.is_stopped():
		if weapon.is_magazine_full():
			return BeehaveNode.SUCCESS
		else:
			self.play_reload_animation()
			self.reload_cooldown.start(weapon.reload_time)
	return BeehaveNode.RUNNING

func shoot() -> int:
	if not aim_target:
		push_error("No aim target to shoot at!")

	if not fire_cooldown.is_stopped():
		return BeehaveNode.RUNNING

	if not weapon.spend_bullet():
		# TODO: Dry fire sound
		return BeehaveNode.FAILURE

	fire_cooldown.start(1.0 / weapon.rate_of_fire)

	play_fire_animation()

	vision_raycast.target_position = weapon.apply_spread_to_target(vision_raycast.to_local(aim_target.get_position_to_shoot_at()), aim_target.get_spread_modifier()) * 20.0
	vision_raycast.force_raycast_update()

	var collided_with = vision_raycast.get_collider()

	if not collided_with:
		weapon.spawn_tracer(barrel_end)
		return BeehaveNode.SUCCESS

	var collision_position: Vector3 = vision_raycast.get_collision_point()
	var collision_normal: Vector3 = vision_raycast.get_collision_normal()

	weapon.spawn_tracer(barrel_end, collision_position)
	if collided_with.is_in_group('player'):
		collided_with.take_damage(weapon.damage)
	else:
		weapon.spawn_bullethole(collided_with, collision_position, collision_normal)

	return BeehaveNode.SUCCESS

func take_damage(damage_taken: float):
	health -= damage_taken
	if health <= 0:
		self.die()

func die():
	# TODO: Animation and other things
	self.queue_free()

func sees_player() -> bool:
	return VisionHelper.sees_player(vision_raycast, player)

func is_crouching() -> bool:
	return should_crouch

func _on_reload_cooldown_timeout() -> void:
	self.weapon.refill_magazine()

func play_look_around_animation() -> int:
	if animation_timer.is_stopped():
		if animation_is_done:
			animation_is_done = false
			return BeehaveNode.SUCCESS
		animation_timer.start(4.0)
		animation_tree.set('parameters/look_around/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return BeehaveNode.RUNNING

func cancel_look_around_animation() -> void:
	animation_tree.set('parameters/look_around/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_timer.stop()

func _on_animation_timer_timeout() -> void:
	animation_is_done = true
