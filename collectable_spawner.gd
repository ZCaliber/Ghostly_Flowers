extends Area2D

var Ghostball = preload("res://t_1_collectable.tscn")
var SleepyBall = preload("res://sleepy_ball.tscn")
var spawn_low = 1.25
var spawn_high = 2.0
var spawn_interval = randf_range(spawn_low, spawn_high)
var local_difficulty = 0

@onready var main_scene : Node = null

func _on_progression(difficulty: Variant) -> void:
	local_difficulty = difficulty  # Update local difficulty value
	adjust_spawn_times()  # Call the function to adjust spawn times
	
func adjust_spawn_times(): # Decreases spawn intervals
	spawn_low = 1.25 - (local_difficulty * 0.25)  # Decrease spawn_low by 0.25 per difficulty point
	if spawn_low < 0.25:
		spawn_low = 0.25  # Set a minimum limit so spawn_low doesn't go too low
	if spawn_low == 0.25:
		spawn_high = 2.0 - (local_difficulty - 4 * 0.25)
		if spawn_high < 1.0:
			spawn_high = 1.0
		
func _ready():
	main_scene = get_parent()  # Reference to the Main scene or node
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", Callable(self, "_spawn_collectable"))
	add_child(spawn_timer)

func _spawn_collectable():
	var collectable = Ghostball.instantiate()

	var area_shape = %CollisionShape2D.shape
	if area_shape is RectangleShape2D:
		var area_rect = %CollisionShape2D.scale
		var global_area_position = %CollisionShape2D.global_position

		var x_min = global_area_position.x - (area_rect.x * 9.5)
		var x_max = global_area_position.x + (area_rect.x * 9.5)
		var x_position = randf_range(x_min, x_max)

		collectable.position = Vector2(x_position, global_position.y - 50)  # Adjust y to spawn off-screen if needed
		get_parent().add_child(collectable)

		# Call the Main script function to connect signals for this collectable
		main_scene.on_collectable_spawned(collectable)
	else:
		print("Shape is not RectangleShape2D")
