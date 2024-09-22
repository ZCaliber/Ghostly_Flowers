extends Control
@onready var starty = $MarginContainer/VBoxContainer/Start

func _ready() -> void:
	starty.grab_focus()
	$AnimationTimer.start()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_animation_timer_timeout() -> void:
	$GhostyAnimation.play("Slide")
