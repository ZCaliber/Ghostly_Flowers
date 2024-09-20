extends Node2D

@onready var player = $"../Ghost"
@onready var off_screen_indicator = $"."  # Reference your indicator sprite

var top_edge: int = 0  # Declare top_edge as a global variable

func _ready() -> void:
	# Check if player and indicator exist
	if player == null:
		print("Player node not found!")
	if off_screen_indicator == null:
		print("Indicator node not found!")

func _physics_process(delta) -> void:
	var camera := get_viewport().get_camera_2d()

	if camera != null:
		var viewport_size = get_viewport_rect().size / camera.zoom
		var camera_position = camera.global_position
		top_edge = camera_position.y - (viewport_size.y / 2)  # Store top_edge globally

func _process(delta):
	# Check if player and indicator exist before accessing their properties
	if player != null and off_screen_indicator != null:
		# Update the indicator's x position to match the player's
		off_screen_indicator.position.x = player.position.x

		# Check if player is off the top of the screen
		if player.position.y < top_edge - 100:
			off_screen_indicator.visible = true
		else:
			off_screen_indicator.visible = false
