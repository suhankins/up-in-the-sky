extends AnimatableCharacter
class_name Player

@export var camera: Camera3D

@export var weapon: Weapon

@export var crouch_speed: float = 1.0
@export var walk_speed: float = 2.0

## "Coyote" fire timer
## i.e. when you press fire right before fire timer is over
@export var coyote_fire_time: float = 0.1

@export var max_health: float = 5.0
@onready var health: float = max_health
# Points per second
@export var regen_health: float = 2.0
signal health_changed(current_health: float, max_health: float)

@export var regeneration_time: float = 2.0
@onready var regeneration_cooldown: Timer = $RegenCooldown

@onready var shooting_raycast: RayCast3D = $ShootingRaycast
@onready var pushing_raycast: RayCast3D = $PushingRaycast

@onready var coyote_fire_cooldown: Timer = $CoyoteFire
@onready var fire_cooldown: Timer = $FireCooldown
@onready var reload_cooldown: Timer = $ReloadCooldown

@onready var cursor: Sprite3D = $Cursor
@onready var barrel_end: Node3D = $Model/Torso/LeftArm/Gun/GunMesh/BarrelEnd

@onready var standing_raycast_origin: Node3D = $StandingRaycastOrigin
@onready var crouching_raycast_origin: Node3D = $CrouchingRaycastOrigin

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision


func _ready() -> void:
	self.reset_shooting_raycast()


func reset_shooting_raycast():
	shooting_raycast.target_position = Vector3(0, 0, -1) * weapon.bullet_distance
	shooting_raycast.target_position.x = 0
	shooting_raycast.target_position.y = 0
	pushing_raycast.target_position = Vector3(0, 0, -1) * weapon.bullet_distance
	pushing_raycast.target_position.x = 0
	pushing_raycast.target_position.y = 0


func _process(delta: float):
	look_at_cursor()
	move_aim()
	animate_legs()
	update_collision()
	update_regeneration(delta)


func update_regeneration(delta: float) -> void:
	if regeneration_cooldown.is_stopped() and health <= max_health:
		health += delta * regen_health
		if health > max_health:
			health = max_health
		health_changed.emit(health, max_health)


func look_at_cursor():
	if not camera:
		push_error("No camera!")

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_position(mouse_pos, 0)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var cursor_position = (
		Plane(Vector3(0, 1, 0), shooting_raycast.global_position.y).intersects_ray(from, to)
	)

	if cursor_position:
		self.look_at(cursor_position)
	self.rotation.x = 0
	self.rotation.z = 0


func update_collision():
	standing_collision.disabled = is_crouching()
	crouching_collision.disabled = not is_crouching()


func get_raycast_position() -> Vector3:
	return (crouching_raycast_origin if is_crouching() else standing_raycast_origin).position


func move_aim():
	shooting_raycast.position = get_raycast_position()
	if not shooting_raycast.get_collider():
		cursor.hide()
		return

	cursor.show()
	cursor.global_position = shooting_raycast.get_collision_point()


func is_crouching():
	return Input.is_action_pressed("crouch")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	handle_movement()
	handle_shoot()
	handle_reload()

	move_and_slide()


func handle_movement():
	if not camera:
		push_error("No camera!")

	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction = (
		Vector3(input_dir.x, 0, input_dir.y)
		. rotated(Vector3(0, 1, 0), camera.rotation.y)
		. normalized()
	)
	var speed = self.get_speed()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


func handle_shoot():
	if not Input.is_action_just_pressed("fire") and coyote_fire_cooldown.is_stopped():
		return

	if not fire_cooldown.is_stopped() or not reload_cooldown.is_stopped():
		if coyote_fire_cooldown.is_stopped():
			coyote_fire_cooldown.start(coyote_fire_time)
		return

	fire_cooldown.start(1.0 / weapon.rate_of_fire)

	if not weapon.spend_bullet():
		# TODO: Dry fire sound
		return

	play_fire_animation()

	shooting_raycast.target_position = weapon.apply_spread_to_target(
		shooting_raycast.target_position, get_spread_modifier()
	)
	pushing_raycast.target_position = shooting_raycast.target_position

	shooting_raycast.force_raycast_update()
	pushing_raycast.force_raycast_update()

	self.reset_shooting_raycast()

	self.handle_shoot_shooting_raycast()
	self.handle_shoot_pushing_raycast()


func handle_shoot_pushing_raycast():
	var collided_with = pushing_raycast.get_collider()

	if not collided_with:
		return

	if collided_with is SoftBody3D:
		weapon.spawn_softbody_pusher(collided_with, pushing_raycast.get_collision_point(), self)


func handle_shoot_shooting_raycast():
	var collided_with = shooting_raycast.get_collider()

	if not collided_with:
		weapon.spawn_tracer(barrel_end)
		return

	var collision_position: Vector3 = shooting_raycast.get_collision_point()
	var collision_normal: Vector3 = shooting_raycast.get_collision_normal()

	weapon.spawn_tracer(barrel_end, collision_position)
	print_debug(collided_with)
	if "take_bullet_damage" in collided_with:
		collided_with.take_bullet_damage(weapon.damage, collision_position)
	elif "take_damage" in collided_with:
		collided_with.take_damage(weapon.damage)
	elif collided_with is StaticBody3D:
		weapon.spawn_bullethole(collided_with, collision_position, collision_normal)


func take_damage(damage_taken: float):
	self.health -= damage_taken
	health_changed.emit(self.health, max_health)
	regeneration_cooldown.start(regeneration_time)
	if self.health <= 0:
		self.die()


func die():
	# TODO: Animations, UI, etc.
	get_tree().reload_current_scene()


func get_spread_modifier() -> float:
	var modifier = 1.0
	if self.is_crouching():
		modifier *= 0.8
	return modifier


func handle_reload():
	if not Input.is_action_just_pressed("reload") or weapon.is_magazine_full():
		return

	if not reload_cooldown.is_stopped():
		return

	reload_cooldown.start(weapon.reload_time)
	weapon.start_reload()
	play_reload_animation()


func _on_reload_cooldown_timeout() -> void:
	weapon.refill_magazine()


func get_speed() -> float:
	return self.crouch_speed if is_crouching() else self.walk_speed
