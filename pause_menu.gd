extends Control
signal music_volume # Signal for volume control when paused

func resume() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	$".".visible = false
	emit_signal("music_volume")
	
func pause() -> void:
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	$".".visible = true
	emit_signal("music_volume")
	
func PressEsc() -> void:
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused == false:
		pause()
		
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused == true:
		resume()
		
func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	PressEsc()
