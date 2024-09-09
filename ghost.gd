extends CharacterBody2D

const SPEED = 2000.0
const FLOOR_SPEED_BOOST = 2.0  # Multiplier for speed on the floor
const AIR_SPEED_DECAY = 0.05  # Fine-tuning for air speed deceleration
const FLOOR_SPEED_DECAY = 0.2  # Fine-tuning for floor speed deceleration
const MIN_AIR_SPEED = SPEED * 1.0  # Minimum speed in the air

var current_direction = 0  # -1 for left, 1 for right, 0 for none
var velocity_x_floor_boost = 0.0  # Variable to store boosted floor speed
var flight = 0.9 # Flight (Anti-gravity)
var jump = -1500.0 # Jump velocity
var drop = 5 # Drop speed multiplier

func _physics_process(delta: float) -> void:
	# Handle gravity while flying
	if not is_on_floor():
		if Input.is_action_pressed("ui_down"):
			velocity += get_gravity() * drop * delta
		if Input.is_action_pressed("ui_up"):
			velocity += get_gravity() * flight * delta * -1
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump

	# Determine the direction based on input.
	var input_left = Input.is_action_pressed("ui_left")
	var input_right = Input.is_action_pressed("ui_right")

	if input_left and not input_right:
		current_direction = -1
	elif input_right and not input_left:
		current_direction = 1
	else:
		current_direction = 0

	# If the player is on the floor, boost their speed
	if is_on_floor():
		velocity_x_floor_boost = SPEED * FLOOR_SPEED_BOOST
		velocity.x = current_direction * velocity_x_floor_boost
	else:
		# Smoothly reduce speed while airborne
		if abs(velocity_x_floor_boost) > MIN_AIR_SPEED:
			velocity_x_floor_boost = lerp(velocity_x_floor_boost, SPEED, AIR_SPEED_DECAY)
		velocity.x = current_direction * velocity_x_floor_boost

	# Apply deceleration if no direction is held.
	if current_direction == 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FLOOR_SPEED_DECAY)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_SPEED_DECAY)

	# Flip the sprite based on the current direction
	if current_direction != 0:
		$Sprite.flip_h = (current_direction == 1)

	move_and_slide()
