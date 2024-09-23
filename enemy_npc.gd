extends AnimatableCharacter
class_name EnemyNPC

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: Player = get_tree().get_nodes_in_group('player')[0]
@onready var cover_detection: Area3D = $CoverDetection

@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var shooting_raycast: RayCast3D = $ShootingRaycast
@onready var pushing_raycast: RayCast3D = $PushingRaycast

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision

@onready var fire_cooldown: Timer = $FireCooldown
@onready var reload_cooldown: Timer = $ReloadCooldown
@onready var movement_cooldown: Timer = $MovementCooldown

@onready var behavior_tree: BeehaveTree = $BeehaveTree

@export var crouch_speed: float = 0.75
@export var walk_speed: float = 1.5
@export var patrol_speed: float = 1.0

var should_crouch: bool = false
## Reference to current navigation move_target
var move_target: Node3D = null

var aim_target: AimTarget = null

@export var weapon_template: Weapon
@onready var weapon: Weapon = self.weapon_template.duplicate()
@export var barrel_end: Node3D

@export var health: float = 3
var dead: bool = false

@export var on_damage_effect_scene: PackedScene

@export var patrol_points: Array[Node3D] = []
@export var blackboard: NPCBlackboard
var was_just_shot: bool = false


func _ready() -> void:
	navigation_agent.target_desired_distance = 0.05
	assert(blackboard != null, "No blackboard set")
	behavior_tree.blackboard = blackboard
	await get_tree().process_frame
	var list_of_npcs = blackboard.get_value(NPCBlackboard.LIST_OF_NPCS).duplicate()
	list_of_npcs.append(self)
	blackboard.set_value(NPCBlackboard.LIST_OF_NPCS, list_of_npcs)


func _process(_delta: float) -> void:
	if dead:
		return
	update_collision()
	update_rotation()


func _physics_process(_delta: float) -> void:
	if dead:
		return
	sees_player()
	animate_legs()
	update_animation_alert_state()
	velocity = Vector3.ZERO


func get_sort_by_distance(to: Vector3 = self.global_position):
	return func sort_by_distance(a: Node3D, b: Node3D):
		return a.global_position.distance_to(to) < b.global_position.distance_to(to)

func find_closest_viable_flank() -> NumberAndNode3DTuple:
	if blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION) == null:
		return NumberAndNode3DTuple.new(INF, null)
	var flanks = get_tree().get_nodes_in_group('flanks')
	flanks.sort_custom(get_sort_by_distance())
	for flank in flanks:
		if flank.is_valid_flank_for_player_position(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION)):
			return NumberAndNode3DTuple.new(self.global_position.distance_squared_to(flank.global_position), flank)
	return NumberAndNode3DTuple.new(INF, null)

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
	if covers.size() == 0:
		return null
	covers.sort_custom(get_sort_by_distance())
	if blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION) == null:
		return covers[0]
	for cover: Cover in covers:
		if cover.is_safe_from_vector(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION)):
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
	return current_cover.is_safe_from_vector(blackboard.get_value(NPCBlackboard.LAST_PLAYER_POSITION))

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
		var direction = VectorHelper.get_direction(global_position, destination)
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

func set_aim_target_node(node: Node3D) -> void:
	self.aim_target = AimTarget.aim_target_from_node(node)

func reset_aim_target() -> void:
	self.aim_target = null


func is_reloading() -> bool:
	return not self.reload_cooldown.is_stopped()


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
		return BeehaveNode.FAILURE

	if not fire_cooldown.is_stopped():
		return BeehaveNode.RUNNING

	if not weapon.spend_bullet():
		# TODO: Dry fire sound
		return BeehaveNode.FAILURE

	fire_cooldown.start(1.0 / weapon.rate_of_fire)

	play_fire_animation()

	shooting_raycast.target_position = weapon.apply_spread_to_target(shooting_raycast.to_local(aim_target.get_position_to_shoot_at()), aim_target.get_spread_modifier()) * 20.0
	pushing_raycast.target_position = shooting_raycast.target_position
	shooting_raycast.force_raycast_update()
	pushing_raycast.force_raycast_update()

	handle_pushing_raycast()
	return handle_shooting_raycast()


func handle_shooting_raycast() -> int:
	var collided_with = shooting_raycast.get_collider()

	if not collided_with:
		weapon.spawn_tracer(barrel_end)
		return BeehaveNode.SUCCESS

	var collision_position: Vector3 = shooting_raycast.get_collision_point()
	var collision_normal: Vector3 = shooting_raycast.get_collision_normal()

	weapon.spawn_tracer(barrel_end, collision_position)
	if "take_bullet_damage" in collided_with:
		collided_with.take_bullet_damage(weapon.damage, collision_position)
	elif "take_damage" in collided_with:
		collided_with.take_damage(weapon.damage)
	elif collided_with is StaticBody3D:
		weapon.spawn_bullethole(collided_with, collision_position, collision_normal)

	return BeehaveNode.SUCCESS


func handle_pushing_raycast():
	var collided_with = pushing_raycast.get_collider()

	if not collided_with:
		return

	if collided_with is SoftBody3D:
		weapon.spawn_softbody_pusher(collided_with, pushing_raycast.get_collision_point(), self)


func take_bullet_damage(damage_taken: float, collision_position: Vector3) -> void:
	print_debug('bullet damage taken')
	self.take_damage(damage_taken)
	var instance = on_damage_effect_scene.instantiate()
	add_child(instance)
	instance.global_position = collision_position
	instance.global_rotation.y = PI


func take_damage(damage_taken: float):
	was_just_shot = true
	health -= damage_taken
	if health <= 0 and not dead:
		self.die()
	await get_tree().process_frame
	was_just_shot = false


func die():
	blackboard.set_value(
		NPCBlackboard.LIST_OF_NPCS,
		blackboard.get_value(NPCBlackboard.LIST_OF_NPCS).filter(func(npc): return npc != self)
	)
	self.dead = true
	behavior_tree.queue_free()
	animation_tree.set('parameters/die/blend_amount', 1.0)
	aim_target = null
	crouching_collision.queue_free()
	standing_collision.queue_free()
	navigation_agent.queue_free()


func sees_player() -> bool:
	if VisionHelper.sees_player(vision_raycast, player):
		blackboard.set_value(
			NPCBlackboard.LAST_PLAYER_POSITION,
			VectorHelper.get_with_y(player.global_position, player.get_raycast_position().y)
		)
		return true
	return false



func is_crouching() -> bool:
	return should_crouch


func can_move() -> bool:
	return movement_cooldown.is_stopped()


func start_movement_cooldown() -> void:
	movement_cooldown.start()


func _on_reload_cooldown_timeout() -> void:
	self.weapon.refill_magazine()
