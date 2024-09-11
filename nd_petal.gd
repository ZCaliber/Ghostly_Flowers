extends Node2D

var number_of_petals = 5 # Number of petals
var petal_distance = 120 # Distance from the collectable center
var petal_angle = 360.0 / number_of_petals # Angle between each petal
var petal_texture: Texture = preload("res://NoDirectionPetal.png") # Preload the petal texture (replace with the correct path to your texture)


func _ready():
	# Spawn the petals dynamically
	spawn_petals(global_position)  # Pass the current global position of the instance

func spawn_petals(center_position: Vector2):
	for i in range(number_of_petals):
		# Create a new Sprite2D for each petal
		var petal_sprite = Sprite2D.new()
		petal_sprite.texture = petal_texture
		petal_sprite.z_index = -1  # Ensure the petals are drawn below the collectable
		# Calculate the angle in radians for the current petal
		var angle_in_radians = deg_to_rad(i * petal_angle)

		# Set the position relative to the center of the initial petal
		petal_sprite.position = Vector2(petal_distance * cos(angle_in_radians), petal_distance * sin(angle_in_radians))

		# Rotate the petal to face outward, minus 4.86 is perfect sprite alignment
		petal_sprite.rotation = angle_in_radians - 4.86 

		# Add the petal to this Node2D (the current instance, i.e., the root petal)
		add_child(petal_sprite)

		# Debug print for petal positions
		# print("Petal", i, "position:", petal_sprite.position)
