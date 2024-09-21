extends AudioStreamPlayer

var paused = false

func _on_pause() -> void:
	paused = !paused  # Toggle the paused state
	if paused == true:  # Comparison with '=='
		self.volume_db -= 10  # Decrease the volume
		# print("Lowering volume", volume_db)
	else:
		self.volume_db += 10  # Increase the volume
		# print("Raising volume")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../CanvasLayer/PauseMenu".connect("music_volume", Callable(self, "_on_pause"))
