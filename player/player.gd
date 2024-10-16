extends AnimatableCharacter
class_name Player

@export var camera: Camera3D

@export var weapon_template: Weapon
@onready var weapon: Weapon = self.weapon_template.duplicate()

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

var dead = false

@export var regeneration_time: float = 2.0
@onready var regeneration_cooldown: Timer = $RegenCooldown

@onready var shooting_raycast: RayCast3D = $ShootingRaycast
@onready var pushing_raycast: RayCast3D = $PushingRaycast
@onready var can_stand_raycast: RayCast3D = $CanStandRaycast

@onready var coyote_fire_cooldown: Timer = $CoyoteFire
@onready var fire_cooldown: Timer = $FireCooldown
@onready var reload_cooldown: Timer = $ReloadCooldown

@onready var cursor: Sprite3D = $Cursor
@onready var barrel_end: Node3D = $Model/PlayerAgent/Torso/LeftArm/Gun/GunMesh/BarrelEnd

@onready var standing_raycast_origin: Node3D = $StandingRaycastOrigin
@onready var crouching_raycast_origin: Node3D = $CrouchingRaycastOrigin

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision

@onready var laser: Node3D = $Laser


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
	if dead:
		return
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
	self.laser.position.y = shooting_raycast.position.y
	var collided_with = shooting_raycast.get_collider()
	if not collided_with:
		self.laser.rotation = Vector3.ZERO
		self.laser.scale.z = self.weapon.bullet_distance
		cursor.hide()
		return

	cursor.show()
	var collision_point = shooting_raycast.get_collision_point()
	cursor.global_position = collision_point
	self.laser.look_at(collision_point)
	self.laser.scale.z = self.laser.global_position.distance_to(collision_point)
	if collided_with is EnemyNPC:
		cursor.modulate = Color.RED
	else:
		cursor.modulate = Color.WHITE


func is_crouching() -> bool:
	return Input.is_action_pressed("crouch") or not can_stand()


func can_stand() -> bool:
	can_stand_raycast.force_raycast_update()
	return not can_stand_raycast.is_colliding()


func _physics_process(delta: float) -> void:
	if dead:
		return
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
	if self.health <= 0 and not dead:
		self.die()


func die():
	self.dead = true
	self.get_parent_node_3d().restart()


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

	self.laser.visible = false
	reload_cooldown.start(weapon.reload_time)
	weapon.start_reload()
	play_reload_animation()


func _on_reload_cooldown_timeout() -> void:
	self.laser.visible = true
	weapon.refill_magazine()


func get_speed() -> float:
	return self.crouch_speed if is_crouching() else self.walk_speed
