extends Control
signal music_volume # Signal for volume control when paused
@onready var resumey = $MarginContainer/VBoxContainer/Resume
var music_quiet: bool = false
var options_open: bool = false

signal quitting

func _ready() -> void:
	if GlobalOptions.highscore != 0:
		$Highscore.text = "Highscore: " + str(GlobalOptions.highscore)
	else:
		$HSBacking.visible = false
		$Highscore.visible = false
	resumey.grab_focus()
		# Initialize sliders with the current volume levels from the global settings
	$MarginContainerOptions/VBoxContainer/Music.value = GlobalOptions.music_volume
	$MarginContainerOptions/VBoxContainer/Sound.value = GlobalOptions.sound_volume

func resume() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	$".".visible = false
	$Ghosty.visible = false
	$MarginContainerOptions.visible = false
	$Backing.visible = false
	# Reset GhostyDelay timer
	$GhostyDelay.stop()  # Stop the timer if it hasn't timed out yet
	if music_quiet == true:
		music_quiet = false
		emit_signal("music_volume")
	else:
		pass
	options_open = false
	# Reset GhostyFadeIn animation
	$GhostyFadeIn.stop()  # Stop the animation if it's playing
	$GhostyFadeIn.seek(0, true)  # Reset the animation to the start

func pause() -> void:
	if GlobalOptions.highscore != 0:
		$Highscore.text = "Highscore: " + str(GlobalOptions.highscore)
	else:
		$HSBacking.visible = false
		$Highscore.visible = false
	
	get_tree().paused = true
	$GhostyDelay.start()  # Start the timer again
	$AnimationPlayer.play("blur")
	$".".visible = true
	emit_signal("music_volume")
	$Ghosty.modulate = Color(1, 1, 1, 0)
	$Ghosty.visible = true
	resumey.grab_focus()
	music_quiet = true

func PressEsc() -> void:
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	if options_open == false:
		options_open = true
		$MarginContainerOptions.visible = true
		$Backing.visible = true
		if music_quiet == true:
			emit_signal("music_volume")
			music_quiet = false
		else:
			pass
	elif options_open == true:
		options_open = false
		$MarginContainerOptions.visible = false
		$Backing.visible = false
		if music_quiet == false:
			emit_signal("music_volume")
			music_quiet = true
		else:
			pass
			
func _on_quit_pressed() -> void:
	emit_signal("quitting")
	get_tree().quit()


func _process(delta):
	PressEsc()

func _on_ghosty_delay_timeout() -> void:
	$GhostyFadeIn.play("FadeIn")
