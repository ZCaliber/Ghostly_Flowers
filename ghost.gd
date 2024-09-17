extends CharacterBody2D

@warning_ignore("unused_signal")
signal directions(horizontal_direction, vertical_direction)

const SPEED = 2000.0
const FLOOR_SPEED_BOOST = 2.0  # Multiplier for speed on the floor
# const AIR_SPEED_DECAY = 500.00  # Fine-tuning for air speed deceleration
const HORIZONTAL_DECELERATION = 1000.0  # Adjustable deceleration rate when no input is pressed (airborne)
const BOOST_DECAY_RATE = 3.0  # Rate at which the boosted speed decays to normal airspeed

var horizontal_input = 0  # For input-based movement (-1 for left, 1 for right)
var vertical_input = 0  # For input-based vertical movement (-1 for down, 1 for up)
var horizontal_direction = 0  # For movement-based direction (-1 for left, 1 for right)
var vertical_direction = 0  # For movement-based direction (-1 for down, 1 for up)
var previous_direction = 0  # To store the last valid direction from input
var velocity_x_floor_boost = 0.0  # To store boosted floor speed
var lingering_boost_speed = 0.0  # Speed after leaving the floor to decay
var flight = 0.6  # Flight (Anti-gravity)
var jump = -1500.0  # Jump velocity
var drop = 5  # Drop speed multiplier

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# Emit signal with the current movement directions
	emit_signal("directions", horizontal_direction, vertical_direction)

func _physics_process(delta: float) -> void:
	# Handle input
	_handle_input()

	# Update the movement-based direction
	_update_movement_direction()

	# Apply gravity and flight
	_apply_gravity_and_flight(delta)

	# Handle horizontal movement and apply deceleration logic
	_handle_horizontal_movement(delta)

	# Flip the sprite based on the current movement direction
	if horizontal_direction != 0:
		for node in get_tree().get_nodes_in_group("CharacterSprite"):
			if node is Sprite2D:
				node.flip_h = (horizontal_direction == 1)

	move_and_slide()

# Handle input separately for movement
func _handle_input() -> void:
	# Horizontal input
	var input_left = Input.is_action_pressed("ui_left")
	var input_right = Input.is_action_pressed("ui_right")
	if input_left and not input_right:
		horizontal_input = -1
		previous_direction = -1
	elif input_right and not input_left:
		horizontal_input = 1
		previous_direction = 1
	elif input_left and input_right:
		horizontal_input = previous_direction
	else:
		horizontal_input = 0

	# Vertical input (for flight or drop)
	if Input.is_action_pressed("ui_up"):
		vertical_input = 1
	elif Input.is_action_pressed("ui_down"):
		vertical_input = -1
	else:
		vertical_input = 0

func _update_movement_direction() -> void:
	# Update horizontal direction based on actual movement
	if velocity.x < 0:
		horizontal_direction = -1  # Moving left
	elif velocity.x > 0:
		horizontal_direction = 1  # Moving right
	else:
		horizontal_direction = 0  # No horizontal movement

	# Update vertical direction based on actual velocity
	if velocity.y < 0:
		vertical_direction = 1  # Moving up
	elif velocity.y > 0:
		vertical_direction = -1  # Moving down
	else:
		vertical_direction = 0  # No vertical movement

func _apply_gravity_and_flight(delta: float) -> void:
	# Handle gravity while flying
	if not is_on_floor():
		if vertical_input == -1:  # Drop
			velocity += get_gravity() * drop * delta
		elif vertical_input == 1:  # Flight (anti-gravity)
			velocity += get_gravity() * flight * delta * -1
		else:
			velocity += get_gravity() * delta

	# Handle jumping
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump

func _handle_horizontal_movement(delta: float) -> void:
	# Horizontal movement and boost logic
	if is_on_floor():
		velocity_x_floor_boost = SPEED * FLOOR_SPEED_BOOST
		velocity.x = horizontal_input * velocity_x_floor_boost
		lingering_boost_speed = velocity_x_floor_boost  # Set lingering boost speed to current boosted speed
	else:
		# Gradually decay the lingering boost speed towards normal airspeed
		lingering_boost_speed = lerp(lingering_boost_speed, SPEED, BOOST_DECAY_RATE * delta)
		
		# Apply movement while airborne, using lingering boost speed for smoother transitions
		if horizontal_input != 0:
			velocity.x = horizontal_input * lingering_boost_speed
		else:
			# Gradual deceleration when no input is pressed
			velocity.x = move_toward(velocity.x, 0, HORIZONTAL_DECELERATION * delta)

	# Instant stop on the floor
	if horizontal_input == 0 and is_on_floor():
		velocity.x = 0
