extends CharacterBody3D

@export var camera: Camera3D

@export var walk_speed = 2.0

@export var crouch_speed = 0.5

@export var weapon: Weapon

### "Coyote" fire timer
### i.e. when you press fire right before fire timer is over
@export var coyote_fire_time: float = 0.1

@onready var raycast: RayCast3D = $RayCast3D
@onready var fire_cooldown: Timer = $FireCooldown
@onready var coyote_fire_cooldown: Timer = $CoyoteFire
@onready var reload_cooldown: Timer = $ReloadCooldown
@onready var cursor: Sprite3D = $Cursor
@onready var animation_tree: AnimationTree = $Model/AnimationTree
@onready var barrel_end: Node3D = $Model/Torso/LeftArm/Gun/GunMesh/BarrelEnd

@onready var standing_raycast_origin: Node3D = $StandingRaycastOrigin
@onready var crouching_raycast_origin: Node3D = $CrouchingRaycastOrigin

@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision

func _ready() -> void:
	raycast.target_position = Vector3(0, 0, -1) * weapon.bullet_distance

func _process(_delta: float):
	look_at_cursor()
	move_aim()
	update_movement_animation()
	update_collision()

func look_at_cursor():
	if not camera:
		push_error('No camera!')
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_position(mouse_pos, 0)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var cursor_position = Plane(Vector3(0, 1, 0), raycast.global_position.y).intersects_ray(from, to)

	self.look_at(cursor_position)
	self.rotation.x = 0
	self.rotation.z = 0

func update_collision():
	standing_collision.disabled = is_crouching()
	crouching_collision.disabled = not is_crouching()

func move_aim():
	raycast.position = (crouching_raycast_origin if is_crouching() else standing_raycast_origin).position
	if not raycast.get_collider():
		cursor.hide()
		return
	
	cursor.show()
	cursor.global_position = raycast.get_collision_point()

func is_crouching():
	return Input.is_action_pressed('crouch')

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	handle_movement()
	handle_fire()
	handle_reload()

	move_and_slide()

func handle_movement():
	if not camera:
		push_error('No camera!')

	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3(0, 1, 0), camera.rotation.y).normalized()
	var speed = crouch_speed if is_crouching() else walk_speed

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func handle_fire():
	if not Input.is_action_just_pressed('fire') and coyote_fire_cooldown.is_stopped():
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

	raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
	raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)

	raycast.force_raycast_update()

	raycast.target_position.x = 0
	raycast.target_position.y = 0

	var collided_with: CollisionObject3D = raycast.get_collider()

	if not collided_with:
		weapon.spawn_tracer(barrel_end)
		return

	var collision_position: Vector3 = raycast.get_collision_point()
	var collision_normal: Vector3 = raycast.get_collision_normal()

	weapon.spawn_tracer(barrel_end, collision_position)
	weapon.spawn_bullethole(collided_with, collision_position, collision_normal)

func handle_reload():
	if not Input.is_action_just_pressed('reload'):
		return

	if not reload_cooldown.is_stopped():
		return

	reload_cooldown.start(weapon.reload_time)
	play_reload_animation()

func play_reload_animation():
	animation_tree.set('parameters/reload/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func play_fire_animation():
	animation_tree.set('parameters/fire_gun/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func update_movement_animation():
	var velocity_angle = velocity.signed_angle_to(Vector3(0, 0, -1), Vector3(0, -1, 0))
	var difference = velocity_angle - self.rotation.y
	var movement_speed_ratio = velocity.length() / (crouch_speed if is_crouching() else walk_speed)
	var leg_vector = Vector2(sin(difference), cos(difference)) * movement_speed_ratio

	animation_tree.set('parameters/walk_blend_space/blend_position', leg_vector)
	animation_tree.set('parameters/crouch_blend_space/blend_position', leg_vector)
	animation_tree.set("parameters/Transition/transition_request", 'crouching' if is_crouching() else 'standing')


func _on_reload_cooldown_timeout() -> void:
	weapon.refill_magazine()
