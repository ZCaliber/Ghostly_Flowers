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

# Preload the petal scene
var no_direction: PackedScene = preload("res://nd_petal.tscn")

# Function to spawn petals when collectable becomes active
func activate_petals():
	if directionals == 0:  # No Directions petals
		var petal_instance = no_direction.instantiate() as Node2D
		if petal_instance:
			# petal_instance.spawn_petals($truecenter.global_position) # Position petals at the true center # Position debug
			add_child(petal_instance)
		else:
			print("Failed to instantiate petal scene")

func _ready():
	# Connect signals for GhostBallCollision
	$GhostBallCollision.connect("body_entered", Callable(self, "_on_Area_2D_body_entered"))
	if not $GhostBallCollision.is_connected("area_entered", Callable(self, "_on_floor_margin_area_entered")):
		$GhostBallCollision.connect("area_entered", Callable(self, "_on_floor_margin_area_entered"))
	
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
	elif body.name == "Ghost" and is_active:
		emit_signal("collected", $center.global_position)
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
