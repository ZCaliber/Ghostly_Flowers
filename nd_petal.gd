extends Node2D

var number_of_petals: int = 0 # Number of petals
var petal_distance: int = 120 # Distance from the collectable center
var petal_texture: Texture = preload("res://Sprites/NoDirectionPetal.png") # Preload the petal texture (replace with the correct path to your texture)
var petal_sprites = [] # Store petal sprites to manipulate later

var max_rotation_speed = 3.0  # The maximum rotation speed in radians per second
var min_rotation_speed = 0.5  # The minimum rotation speed (absolute value)

var initial_rotation_offset: float = 1.6 # Adjust this to align the sprites (in radians)

# Track velocity and position
var velocity = Vector2()  # Store the current velocity
var previous_position = Vector2()  # Track the previous position to calculate velocity

var rotation_offsets = [0.5, 1.6, 2.0, 4.8]

func randomize_petals():
	# Choose a random initial rotation offset from the array
	initial_rotation_offset = rotation_offsets[randi() % rotation_offsets.size()]
	# Custom petal configurations
	if initial_rotation_offset == 1.6:
		petal_distance = 150
		number_of_petals = 8
	elif initial_rotation_offset == 0.5:
		number_of_petals = 6
	else:
		number_of_petals = 5

func _ready():
	randomize_petals()

	# Recalculate petal angle only if there are petals to spawn
	if number_of_petals > 0:
		# Recalculate petal_angle based on the number of petals
		var petal_angle = 360.0 / number_of_petals
		
		# Spawn the petals dynamically with the chosen initial offset
		spawn_petals(global_position)  # Pass the current global position of the instance
		previous_position = global_position  # Initialize the previous position

func spawn_petals(center_position: Vector2):
	# Ensure that the number of petals is greater than zero
	if number_of_petals <= 0:
		return
	
	for i in range(number_of_petals):
		# Create a new Sprite2D for each petal
		var petal_sprite = Sprite2D.new()
		petal_sprite.texture = petal_texture
		petal_sprite.z_index = -1  # Ensure the petals are drawn below the collectable
		
		# Calculate the angle in radians for the current petal
		var angle_in_radians = deg_to_rad(i * (360.0 / number_of_petals))
		
		# Set the position relative to the center of the initial petal
		petal_sprite.position = Vector2(petal_distance * cos(angle_in_radians), petal_distance * sin(angle_in_radians))

		# Apply an initial rotation offset to the petal's rotation itself
		petal_sprite.rotation = angle_in_radians + initial_rotation_offset
		
		# Add the petal to this Node2D (the current instance, i.e., the root petal)
		add_child(petal_sprite)
		petal_sprites.append(petal_sprite) # Store the petal sprite for later rotation manipulation

func _process(delta):
	# Calculate the velocity based on the difference in position between frames
	velocity = (global_position - previous_position) / delta
	
	# Save the current position to use in the next frame
	previous_position = global_position

	# Calculate the rotation speed based on the x velocity
	var rotation_speed = velocity.x * 0.005  # Adjust the multiplier to control rotation speed

	# Clamp the rotation speed between -max_rotation_speed and max_rotation_speed
	rotation_speed = clamp(rotation_speed, -max_rotation_speed, max_rotation_speed)
	
	# Ensure the speed is at least the minimum rotation speed if the collectable is moving
	if abs(rotation_speed) < min_rotation_speed and velocity.x != 0:
		rotation_speed = sign(rotation_speed) * min_rotation_speed

	# Rotate the petals based on the clamped speed
	for i in range(number_of_petals):
		var petal_sprite = petal_sprites[i]
		
		# Calculate the angle in radians for the petal's movement around the center
		var current_angle = petal_sprite.position.angle()  # Get the current angle of the petal
		var new_angle = current_angle + rotation_speed * delta  # Update the angle based on velocity

		# Update the petal's position around the center (keeping the radial distance consistent)
		petal_sprite.position = Vector2(petal_distance * cos(new_angle), petal_distance * sin(new_angle))
		
		# Now rotate the petal itself to keep facing outwards as it moves (keep initial offset)
		petal_sprite.rotation = new_angle + initial_rotation_offset
