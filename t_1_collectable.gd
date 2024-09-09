extends Node2D

@warning_ignore("unused_signal")
signal collected(position: Vector2)
@warning_ignore("unused_signal")
signal missed

var is_active = false
var screen_top = -3000 # Activation threshold
var has_despawned = false
var edge_push = 90 # Buffer for Collectable collision on edge

func _ready():
	# Connect signals for GhostBallCollision
	$GhostBallCollision.connect("body_entered", Callable(self, "_on_Area_2D_body_entered"))
	if not $GhostBallCollision.is_connected("area_entered", Callable(self, "_on_floor_margin_area_entered")):
		$GhostBallCollision.connect("area_entered", Callable(self, "_on_floor_margin_area_entered"))
func _process(delta: float):
	# Activate the collectable when it's above a certain position
	if position.y > screen_top and !is_active:
		is_active = true
		$GhostBall.texture = load("res://GhostBall.png")

var fall_speed = randi_range(400, 800)
var side_speed = Vector2(randf_range(-1000, 1000), 0) # Random horizontal speed

func _physics_process(delta):
	# Get the active camera and its zoom level
	var camera = get_viewport().get_camera_2d()

	# Ensure a camera is available
	if camera != null:
		var viewport_size = get_viewport_rect().size / camera.zoom
		var camera_position = camera.global_position
		var left_edge = camera_position.x - (viewport_size.x / 2)
		var right_edge = camera_position.x + (viewport_size.x / 2)
		var top_edge = camera_position.y - (viewport_size.y / 2)
		var bottom_edge = camera_position.y + (viewport_size.y / 2)

		# Bounce off left and right screen edges
		if position.x <= left_edge + edge_push or position.x >= right_edge - edge_push:
			side_speed.x = -side_speed.x # Reverse horizontal movement
		# Check if the collectable has fallen off the bottom of the viewport
		if position.y > bottom_edge:
			queue_free()  # Remove the collectable when it goes off-screen

	# Vertical movement (falling)
	position.y += fall_speed * delta
	position += side_speed * delta

func _on_Area_2D_body_entered(body):
	# Check if the object is the player (Ghost)
	if body.name == "Ghost" and is_active:
		emit_signal("collected", $center.global_position) # Emit signal with collectable position
		queue_free()
		# print(global_position)
	# Ignore collisions with other collectables
	elif body.is_in_group("Collectable"):
		pass

func _on_floor_margin_area_entered(area: Area2D):
	# Ensure the area is in the "Floor" group (or whatever group your Floor Margin belongs to)
	if area.is_in_group("Floor") and !has_despawned and is_active:
		has_despawned = true
		emit_signal("missed")
		queue_free()
		#print("Hit floor")
