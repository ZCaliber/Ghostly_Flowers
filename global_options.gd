extends Node

@export var music_volume: float = 1.0
@export var sound_volume: float = 1.0
@export var music_muted: bool = false
@export var sound_muted: bool = false
@export var highscore: int
var current_dir = OS.get_executable_path().get_base_dir()
var savefile = current_dir + "/savedata.save"
signal celebrate

# Store the original dB values to adjust relatively
var original_music_dbs: Dictionary = {}
var original_sound_dbs: Dictionary = {}

func apply_volume_settings():
	# Adjust all music nodes, based on their original volume_db settings
	for node in get_tree().get_nodes_in_group("Music"):
		if not original_music_dbs.has(node):
			# Store the original db value for each node
			original_music_dbs[node] = node.volume_db
		
		if music_volume <= 0.0 or music_muted:
			node.volume_db = -80  # Mute
		else:
			# Adjust relative to the original db value
			node.volume_db = original_music_dbs[node] + 10 * log(music_volume)
	
	# Adjust all sound nodes, based on their original volume_db settings
	for node in get_tree().get_nodes_in_group("Sounds"):
		if not original_sound_dbs.has(node):
			# Store the original db value for each node
			original_sound_dbs[node] = node.volume_db
		
		if sound_volume <= 0.0 or sound_muted:
			node.volume_db = -80  # Mute
		else:
			# Adjust relative to the original db value
			node.volume_db = original_sound_dbs[node] + 10 * log(sound_volume)

# Save highscore logic
func save_highscore(highscore):
	var file = FileAccess.open(savefile, FileAccess.WRITE_READ)
	file.store_32(highscore)
	
# Load highscore logic
func load_highscore():
	var file = FileAccess.open(savefile, FileAccess.READ)
	if FileAccess.file_exists(savefile):
		highscore = file.get_32()
	else:
		push_error("File system error!")

func trigger_celebration() -> void:
	emit_signal("celebrate")
	print("Party!")
