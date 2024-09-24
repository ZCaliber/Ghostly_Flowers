extends Control
@onready var starty = $MarginContainer/VBoxContainer/Start
var options_open = false

func _ready() -> void:
	starty.grab_focus()
	$AnimationTimer.start()
	GlobalOptions.apply_volume_settings()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_options_pressed() -> void:
	if options_open == false:
		$MarginContainerOptions.visible = true
		$Backing.visible = true
		options_open = true
	else:
		$MarginContainerOptions.visible = false
		$Backing.visible = false
		options_open = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_animation_timer_timeout() -> void:
	$GhostyAnimation.play("Slide")
