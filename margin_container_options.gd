extends MarginContainer

func _ready() -> void:
	$VBoxContainer/Music.value = GlobalOptions.music_volume
	$VBoxContainer/Sound.value = GlobalOptions.sound_volume

# This function is called when the Music slider value changes
func _on_MusicVolumeSlider_value_changed(value):
	GlobalOptions.music_volume = value  # Update the global music volume
	GlobalOptions.apply_volume_settings()  # Apply the new volume to all music nodes

# This function is called when the Sound slider value changes
func _on_SoundVolumeSlider_value_changed(value):
	GlobalOptions.sound_volume = value  # Update the global sound volume
	GlobalOptions.apply_volume_settings()  # Apply the new volume to all sound nodes

func _on_music_value_changed(value: float) -> void:
	_on_MusicVolumeSlider_value_changed(value)


func _on_sound_value_changed(value: float) -> void:
	_on_SoundVolumeSlider_value_changed(value)
	$TestPop.play()

func _on_mute_music_toggled(toggled_on: bool) -> void:
	GlobalOptions.music_muted = toggled_on
	GlobalOptions.apply_volume_settings()  # Apply the change immediately

func _on_mute_sounds_toggled(toggled_on: bool) -> void:
	GlobalOptions.sound_muted = toggled_on
	GlobalOptions.apply_volume_settings()  # Apply the change immediately
