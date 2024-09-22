extends Control
signal music_volume # Signal for volume control when paused
@onready var resumey = $MarginContainer/VBoxContainer/Resume

func _ready() -> void:
	resumey.grab_focus()

func resume() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	$".".visible = false
	emit_signal("music_volume")
	$Ghosty.visible = false
	
	# Reset GhostyDelay timer
	$GhostyDelay.stop()  # Stop the timer if it hasn't timed out yet

	# Reset GhostyFadeIn animation
	$GhostyFadeIn.stop()  # Stop the animation if it's playing
	$GhostyFadeIn.seek(0, true)  # Reset the animation to the start

func pause() -> void:
	get_tree().paused = true
	$GhostyDelay.start()  # Start the timer again
	$AnimationPlayer.play("blur")
	$".".visible = true
	emit_signal("music_volume")
	$Ghosty.modulate = Color(1, 1, 1, 0)
	$Ghosty.visible = true
	resumey.grab_focus()

func PressEsc() -> void:
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	PressEsc()

func _on_ghosty_delay_timeout() -> void:
	$GhostyFadeIn.play("FadeIn")
