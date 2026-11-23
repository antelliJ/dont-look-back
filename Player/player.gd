extends CharacterBody2D

@export_group("Bounce Physics")
@export var base_bounce_force: float = -450.0
@export var super_bounce_force: float = -700.0
@export var gravity: float = 1200.0

@export_group("Tilt & Horizontal Movement")
@export var max_tilt_angle: float = 35.0 # Degrees
@export var tilt_speed: float = 180.0
@export var tilt_return_speed: float = 120.0
@export var horizontal_boost: float = 400.0
@export var air_friction: float = 150.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


var current_tilt: float = 0.0

var is_offscreen : bool = false

func reset_char() -> void:
	position = Vector2(500, 170)
	velocity = Vector2.ZERO
	current_tilt = 0.0

func play_death() -> void:
	#respawn ig and later reset camera
	reset_char()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		current_tilt += direction * tilt_speed * delta
		current_tilt = clamp(current_tilt, -max_tilt_angle, max_tilt_angle)
	else:
		current_tilt = move_toward(current_tilt, 0.0, tilt_return_speed * delta)
		
	rotation_degrees = current_tilt
	
	velocity.x = move_toward(velocity.x, 0.0, air_friction*delta)
	
	#bounce on ground hit
	if is_on_floor():
		var bounce_power := super_bounce_force if Input.is_action_pressed("ui_accept") else base_bounce_force
		
		var launch_angle := deg_to_rad(current_tilt)
		velocity.y = cos(launch_angle) * bounce_power
		velocity.x = sin(launch_angle) * abs(bounce_power) * (horizontal_boost / 450.0)
	move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_offscreen = true
	await get_tree().create_timer(0.8)
	if is_offscreen:
		play_death()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_offscreen = false
