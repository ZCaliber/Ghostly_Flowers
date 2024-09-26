extends Control
@onready var starty = $MarginContainer/VBoxContainer/Start
var options_open = false
var htp_open = false

func _ready() -> void:
	GlobalOptions.load_highscore()
	starty.grab_focus()
	$AnimationTimer.start()
	GlobalOptions.apply_volume_settings()
	if GlobalOptions.highscore != 0:
		$HSBacking.visible = true
		$HighscoreMarginBox.visible = true
		$HighscoreMarginBox/Highscore.text = "Highscore: " + str(GlobalOptions.highscore)

func _on_start_pressed() -> void:
	$FadeAnimation.play("fade")
	await $FadeAnimation.animation_finished
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

func _on_how_to_play_pressed() -> void:
	if htp_open == false:
		$HTPBacking.visible = true
		$HowTo.visible = true
		htp_open = true
		$ZCal.visible = false
	else:
		$HTPBacking.visible = false
		$HowTo.visible = false
		htp_open = false
		$ZCal.visible = true
