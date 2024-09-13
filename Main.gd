extends Node

var combo_counter = 0  # To track the current combo
var combo_milestones = [10, 20, 25, 150, 200, 250, 300, 350]  # Add more as needed
var difficulty = 0

signal progress(difficulty)

@onready var combo_counter_label: RichTextLabel = $ComboCounter

func _process(delta: float) -> void:
	emit_signal("progress", difficulty) # Emit the difficulty value with the signal

func _ready():
	update_combo_label()

# This function is called by the Spawner script to connect signals for the spawned collectables
func on_collectable_spawned(collectable: Node2D):
	if collectable.has_signal("collected"):
		if not collectable.is_connected("collected", Callable(self, "_on_collectable_collected")):
			collectable.connect("collected", Callable(self, "_on_collectable_collected"))
		# Debug: print("Connected 'collected' signal for: ", collectable.name)
	else:
		print("Collectable has no 'collected' signal!")

	if collectable.has_signal("missed"):
		if not collectable.is_connected("missed", Callable(self, "reset_combo")):
			collectable.connect("missed", Callable(self, "reset_combo"))
		# Debug: print("Connected 'missed' signal for: ", collectable.name)
	else:
		print("Collectable has no 'missed' signal!")

func update_combo_label():
	combo_counter_label.clear()
	combo_counter_label.add_text("Combo: " + str(combo_counter))

func _on_collectable_collected(collectable_position: Vector2):
	#print("Collectable collected!")
	combo_counter += 1  # Increase combo score
	update_combo_label()
	check_combo_milestones()
	# Spawn a new RichTextLabel at the collectable's position
	var score_label = RichTextLabel.new()
	score_label.bbcode_enabled = true
	score_label.set_position(collectable_position)
	if combo_counter in combo_milestones:
		difficulty += 1
		score_label.text = "[tornado radius=40.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8][font_size=300]" + str(combo_counter) + "[/font_size][/rainbow][/tornado]"
	else: score_label.text = "[rainbow freq=1.0 sat=0.8 val=0.8][font_size=200]" + str(combo_counter) + "[/font_size][/rainbow]" # Display combo score
	 # Set a minimum size to ensure visibility
	score_label.set_size(Vector2(2000, 2000)) # Set a minimum size to ensure visibility
	
	# score_label.create_tween()
	# print(score_label.get_children())

	# Tween zone
	if score_label.is_ready() == true:
		score_label.create_tween().tween_property(self, "position", Vector2(0, -1000), 100)
		
	# Drop shadow
	score_label.add_theme_color_override("font_shadow_color", Color("#000", 1))
	score_label.add_theme_constant_override("shadow_outline_size", 30)
	score_label.add_theme_constant_override("shadow_offset_x", 10)
	score_label.add_theme_constant_override("shadow_offset_y", 10)
	
	# Set z_index to a lower value than the player (e.g., -1)
	score_label.z_index = -1
	
	# Get camera edges to clamp the position
	var camera = get_viewport().get_camera_2d()
	if camera != null:
		var viewport = get_viewport()  # Access the current Viewport
		var viewport_size = viewport.get_visible_rect().size / camera.zoom
		var camera_position = camera.global_position
		var left_edge = camera_position.x - (viewport_size.x / 2)
		var right_edge = camera_position.x + (viewport_size.x / 2)
		var top_edge = camera_position.y - (viewport_size.y / 2)
		var bottom_edge = camera_position.y + (viewport_size.y / 2)

		# Clamp the label's position within the screen bounds
		var clamped_x = clamp(score_label.position.x, left_edge + 50, right_edge - 200)  # Keep some margin from edges
		var clamped_y = clamp(score_label.position.y, top_edge + 50, bottom_edge - 50)
		score_label.position = Vector2(clamped_x, clamped_y)
	
	# Add it to main scene
	add_child(score_label)

	# Use a timer to remove the label after a brief time
	var timer = Timer.new()
	if combo_counter in combo_milestones:
		timer.wait_time = 1.5
	else:
		timer.wait_time = 1.0
	timer.one_shot = true
	timer.connect("timeout", Callable(score_label, "queue_free")) # Remove label after time
	add_child(timer)
	timer.start()
	
	# Update the main ComboCounter label
	update_combo_label()
	
func check_combo_milestones(): # Unused
	if combo_counter in combo_milestones:
		show_special_combo_effect(combo_counter)

func reset_combo():
	print("Combo reset!")
	combo_counter = 0  # Reset combo score
	difficulty = 0
	update_combo_label()
	 # Despawn all current collectables
	for collectable in get_tree().get_nodes_in_group("Collectable"):
		collectable.queue_free()  # Safely remove all collectable nodes

func show_special_combo_effect(combo):
	print("Combo Milestone Reached: " + str(combo))
	# Implement special effects here, such as animations or sounds
