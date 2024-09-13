extends Node2D

signal collected(position: Vector2)
signal missed

var is_active = false
var screen_top = -3000 # Activation threshold
var has_despawned = false
var edge_push = 90 # Buffer for Collectable collision on edge
var grace_count = 0 # Number of times grace period is applied
var max_grace = 2 # Maximum number of grace periods allowed
var directionals = 0 # 0 = none, 1 = L/R, 2 = U/D, 3 = Diagonals
var stored_horizontal = 0 # Local variable for player direction, -1 for left, 1 for right, 0 for none
var stored_vertical = 0 # Local variable for player direction,-1 for down, 1 for up, 0 for none
var stored_difficulty = 0 # Local variable for current difficulty

# Preload the petal scene
var no_direction: PackedScene = preload("res://nd_petal.tscn")
var lr_petal: PackedScene = preload("res://lr_petal.tscn")
var ud_petal: PackedScene = preload("res://ud_petal.tscn")
var diag_petal: PackedScene = preload("res://diag_petal.tscn")

# Function to spawn petals when collectable becomes active
func activate_petals():
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
		print("Failed to instantiate petal scene")

# Signal functions
func player_directions(horizontal_direction: Variant, vertical_direction: Variant) -> void: # Connected from ghost.gd
	stored_horizontal = horizontal_direction
	stored_vertical = vertical_direction
	
func _on_progression(difficulty: Variant) -> void: # Connected from Main.gd
	stored_difficulty = difficulty

func _on_directionals_select():
	# Define thresholds for each type of directionals
	# These thresholds and probabilities can be adjusted as needed
	var no_direction_prob = clamp(1.0 - stored_difficulty * 0.05, 0.1, 1.0)  # Probability decreases with difficulty
	var lr_direction_prob = clamp(stored_difficulty * 0.04, 0.1, 0.6)  # L/R becomes more common with difficulty
	var ud_direction_prob = clamp(stored_difficulty * 0.03, 0.05, 0.3)  # U/D directionals increase with difficulty
	var diag_direction_prob = clamp(stored_difficulty * 0.02, 0.01, 0.2)  # Diagonals have the lowest chance but increase slightly

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

func decide_direction():
	# Randomly pick a direction based on the directional type
	if directionals == 1:  # L/R
		if randf() < 0.5:
			$Arrow.rotation_degrees = 0  # Point left
		else:
			$Arrow.rotation_degrees = 180  # Point right
	elif directionals == 2:  # U/D
		if randf() < 0.5:
			$Arrow.rotation_degrees = -90  # Point up
		else:
			$Arrow.rotation_degrees = 90  # Point down
	elif directionals == 3:  # Diagonal
		var diagonal_choice = randi_range(0, 3)
		if diagonal_choice == 0:
			$Arrow.rotation_degrees = -45  # Upper-left
		elif diagonal_choice == 1:
			$Arrow.rotation_degrees = 45  # Upper-right
		elif diagonal_choice == 2:
			$Arrow.rotation_degrees = -135  # Lower-left
		else:
			$Arrow.rotation_degrees = 135  # Lower-right


func _ready():
	var player = get_node("../Ghost") # Directionals node connection
	if player:
		player.connect("directions", Callable(self, "player_directions"))
		
	var main = get_node("..") # Difficulty node connection
	if main:
		main.connect("progress", Callable(self, "_on_progression"))
	
	# Connect signals for GhostBallCollision
	$GhostBallCollision.connect("body_entered", Callable(self, "_on_Area_2D_body_entered"))
	if not $GhostBallCollision.is_connected("area_entered", Callable(self, "_on_floor_margin_area_entered")):
		$GhostBallCollision.connect("area_entered", Callable(self, "_on_floor_margin_area_entered"))
	
	_on_directionals_select()
	decide_direction()
	
	# Create a timer for activation delay
	if not has_node("activation_delay_timer"):
		var timer = Timer.new()
		timer.name = "activation_delay_timer"
		timer.one_shot = true
		timer.wait_time = 1.5 # Delay before activation
		timer.connect("timeout", Callable(self, "_on_activation_timeout"))
		add_child(timer)


func _process(delta: float):
	var timer = get_node("activation_delay_timer")
	var overlapping_bodies = $GhostBallCollision.get_overlapping_bodies()

	if directionals > 0:
		$Arrow.visible = true

	# Activate the collectable when it's above a certain position, no active timer, and collectable isn't active
	if is_active:
		$GhostBall.texture = load("res://GhostBall.png")

	if position.y > screen_top and !is_active and timer.is_stopped():
		is_active = true
		activate_petals()
		
	for body in overlapping_bodies:
		if body.name == "Ghost" and directionals == 0 and is_active:
			emit_signal("collected", $center.global_position)
			queue_free()
			return
		else:
			return

var fall_speed = randi_range(400, 800)
var side_speed = Vector2(randf_range(-1000, 1000), 0) # Random horizontal speed

func _physics_process(delta):
	var camera = get_viewport().get_camera_2d()

	if camera != null:
		var viewport_size = get_viewport_rect().size / camera.zoom
		var camera_position = camera.global_position
		var left_edge = camera_position.x - (viewport_size.x / 2)
		var right_edge = camera_position.x + (viewport_size.x / 2)
		var top_edge = camera_position.y - (viewport_size.y / 2)
		var bottom_edge = camera_position.y + (viewport_size.y / 2)

		# Bounce off left and right screen edges
		if position.x <= left_edge + edge_push or position.x >= right_edge - edge_push:
			side_speed.x = -side_speed.x
		
		if position.y > bottom_edge:
			queue_free()

	position.y += fall_speed * delta
	position += side_speed * delta

func _on_Area_2D_body_entered(body):
	if body.name == "Ghost" and !is_active and directionals > 0:
		_on_activation_delay()
	elif body.name == "Ghost" and is_active and directionals == 0:
		emit_signal("collected", $center.global_position)
		queue_free()
	elif body.name == "Ghost" and is_active and directionals > 0:
	# L/R direction check
		if directionals == 1:
			if (stored_horizontal == -1 and $Arrow.rotation_degrees == 0) or (stored_horizontal == 1 and $Arrow.rotation_degrees == 180):
				emit_signal("collected", $center.global_position)  # Correct direction
				queue_free()
			else:
				emit_signal("missed")  # Wrong direction
				queue_free()

	# U/D direction check
		elif directionals == 2:
			if (stored_vertical == 1 and $Arrow.rotation_degrees == 90) or (stored_vertical == -1 and $Arrow.rotation_degrees == -90):
				emit_signal("collected", $center.global_position)  # Correct direction
				queue_free()
			else:
				emit_signal("missed")  # Wrong direction
				queue_free()

	# Diagonal direction check
		elif directionals == 3:
			var diag_collected = false
		# Upper-left
			if stored_horizontal == -1 and stored_vertical == 1 and $Arrow.rotation_degrees == -45:
				diag_collected = true
		# Upper-right
			elif stored_horizontal == 1 and stored_vertical == 1 and $Arrow.rotation_degrees == 45:
				diag_collected = true
		# Lower-left
			elif stored_horizontal == -1 and stored_vertical == -1 and $Arrow.rotation_degrees == -135:
				diag_collected = true
		# Lower-right
			elif stored_horizontal == 1 and stored_vertical == -1 and $Arrow.rotation_degrees == 135:
				diag_collected = true

			if diag_collected:
				emit_signal("collected", $center.global_position)  # Correct direction
				queue_free()
			else:
				emit_signal("missed")  # Wrong direction
				queue_free()

		
	elif body.is_in_group("Collectable"):
		pass

func _on_floor_margin_area_entered(area: Area2D):
	if area.is_in_group("Floor") and !has_despawned and is_active:
		has_despawned = true
		emit_signal("missed")
		queue_free()

func _on_activation_delay():
	if grace_count < max_grace and directionals > 0:
		$activation_delay_timer.start()
		grace_count += 1
	else:
		is_active = true

func _on_activation_timeout():
	var overlapping_bodies = $GhostBallCollision.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.name == "Ghost":
			_on_activation_delay()
			return
