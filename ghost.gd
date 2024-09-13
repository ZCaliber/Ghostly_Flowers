extends CharacterBody2D

signal directions(horizontal_direction, vertical_direction)

const SPEED = 2000.0
const FLOOR_SPEED_BOOST = 2.0  # Multiplier for speed on the floor
const AIR_SPEED_DECAY = 0.05  # Fine-tuning for air speed deceleration
const FLOOR_SPEED_DECAY = 0.2  # Fine-tuning for floor speed deceleration
const MIN_AIR_SPEED = SPEED * 1.0  # Minimum speed in the air
const HORIZONTAL_DECELERATION = 0.000001  # Adjustable deceleration rate when no input is pressed

var horizontal_direction = 0  # -1 for left, 1 for right, 0 for none
var vertical_direction = 0  # -1 for down, 1 for up, 0 for none
var previous_direction = 0  # Variable to store the last valid direction
var velocity_x_floor_boost = 0.0  # Variable to store boosted floor speed
var flight = 0.9  # Flight (Anti-gravity)
var jump = -1500.0  # Jump velocity
var drop = 5  # Drop speed multiplier

func _process(delta: float) -> void:
	# Signal for collectable collecting
	emit_signal("directions", horizontal_direction, vertical_direction)

func _physics_process(delta: float) -> void:
	# Handle gravity while flying
	if not is_on_floor():
		if Input.is_action_pressed("ui_down"):
			velocity += get_gravity() * drop * delta
			vertical_direction = -1  # Moving down
		elif Input.is_action_pressed("ui_up"):
			velocity += get_gravity() * flight * delta * -1
			vertical_direction = 1  # Moving up
		else:
			velocity += get_gravity() * delta
			vertical_direction = 0  # Not moving vertically
	else:
		vertical_direction = 0  # Reset vertical direction when on the floor

	# Handle jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump

	# Determine the horizontal direction based on input
	var input_left = Input.is_action_pressed("ui_left")
	var input_right = Input.is_action_pressed("ui_right")

	if input_left and not input_right:
		horizontal_direction = -1  # Moving left
		previous_direction = -1  # Store last valid direction
	elif input_right and not input_left:
		horizontal_direction = 1  # Moving right
		previous_direction = 1  # Store last valid direction
	elif input_left and input_right:
		horizontal_direction = previous_direction  # Maintain previous direction
	else:
		horizontal_direction = 0  # No horizontal input

# Update vertical direction based on velocity.y
	if velocity.y < 0:
		vertical_direction = 1  # Moving up
	elif velocity.y > 0:
		vertical_direction = -1  # Moving down
	else:
		vertical_direction = 0  # Not moving vertically

	# If the player is on the floor, boost their speed
	if is_on_floor():
		velocity_x_floor_boost = SPEED * FLOOR_SPEED_BOOST
		velocity.x = horizontal_direction * velocity_x_floor_boost
	else:
		# Smoothly reduce speed while airborne
		if abs(velocity_x_floor_boost) > MIN_AIR_SPEED:
			velocity_x_floor_boost = lerp(velocity_x_floor_boost, SPEED, AIR_SPEED_DECAY)
		velocity.x = horizontal_direction * velocity_x_floor_boost


	# If the player is on the floor, boost their speed
	if is_on_floor():
		velocity_x_floor_boost = SPEED * FLOOR_SPEED_BOOST
		velocity.x = horizontal_direction * velocity_x_floor_boost
	else:
		# Smoothly reduce speed while airborne
		if abs(velocity_x_floor_boost) > MIN_AIR_SPEED:
			velocity_x_floor_boost = lerp(velocity_x_floor_boost, SPEED, AIR_SPEED_DECAY)
		velocity.x = horizontal_direction * velocity_x_floor_boost

	# Apply deceleration when no input is pressed
	if horizontal_direction == 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FLOOR_SPEED_DECAY)
		else:
			# Apply gradual horizontal deceleration when airborne and no input is pressed
			velocity.x = move_toward(velocity.x, 0, HORIZONTAL_DECELERATION * delta)

	# Flip the sprite based on the current horizontal direction
	if horizontal_direction != 0:
		$Sprite.flip_h = (horizontal_direction == 1)

	move_and_slide()
