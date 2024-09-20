extends Sprite2D

var directionals: int = 0


# Preload the petal scene
var no_direction: PackedScene = preload("res://nd_petal.tscn")
var lr_petal: PackedScene = preload("res://lr_petal.tscn")
var ud_petal: PackedScene = preload("res://ud_petal.tscn")
var diag_petal: PackedScene = preload("res://diag_petal.tscn")

func activate_petals() -> void:
	if directionals == 0:  # No Directions petals
		var petal_instance = no_direction.instantiate() as Node2D
		if petal_instance:
			# petal_instance.spawn_petals($truecenter.global_position) # Position petals at the true center # Position debug
			add_child(petal_instance)
	elif directionals == 1:  # Left/Right petals
		var petal_instance = lr_petal.instantiate() as Node2D
		if petal_instance:
			# petal_instance.spawn_petals($truecenter.global_position) # Position petals at the true center # Position debug
			add_child(petal_instance)
	elif directionals == 2:  # Up/Down petals
		var petal_instance = ud_petal.instantiate() as Node2D
		if petal_instance:
			# petal_instance.spawn_petals($truecenter.global_position) # Position petals at the true center # Position debug
			add_child(petal_instance)
	elif directionals == 3:  # Diagonal petals
		var petal_instance = diag_petal.instantiate() as Node2D
		if petal_instance:
			# petal_instance.spawn_petals($truecenter.global_position) # Position petals at the true center # Position debug
			add_child(petal_instance)
	else:
		push_error("Failed to instantiate petal scene")
		
		
func _on_directionals_select() -> void:
	# Define thresholds for each type of directionals
	# These thresholds and probabilities can be adjusted as needed
	var no_direction_prob = clamp(0.05, 0.1, 1.0)  # Probability decreases with difficulty
	var lr_direction_prob = clamp(0.04, 0.1, 0.6)  # L/R becomes more common with difficulty
	var ud_direction_prob = clamp(0.03, 0.05, 0.3)  # U/D directionals increase with difficulty
	var diag_direction_prob = clamp(0.02, 0.01, 0.2)  # Diagonals have the lowest chance but increase slightly

	# Calculate the total probability sum to normalize random selection
	var total_prob = no_direction_prob + lr_direction_prob + ud_direction_prob + diag_direction_prob
	var chance = randf() * total_prob  # Scale chance to total probability

	# Select based on cumulative chance
	if chance < no_direction_prob:
		directionals = 0  # No directional
	elif chance < no_direction_prob + lr_direction_prob:
		directionals = 1  # L/R directionals
	elif chance < no_direction_prob + lr_direction_prob + ud_direction_prob:
		directionals = 2  # U/D directionals
	else:
		directionals = 3  # Diagonals

func _ready() -> void:
	_on_directionals_select()
	activate_petals()
