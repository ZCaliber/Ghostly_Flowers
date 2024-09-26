extends Node2D  # Make sure the script is attached to a node that inherits from Node

@onready var sprite: Sprite2D = $Sprite2D  # Reference to your Sprite2D node
@onready var timer: Timer = $GBTimer       # Timer node to control the intervals between animations
@onready var sight_area: Area2D = $Sight   # The Area2D used for detecting player proximity

# Define your animation frames as textures
@export var neutral_texture: Texture2D = load("res://Sprites/GhostBlock1.png")    # Neutral face texture
@export var blink_texture: Texture2D = load("res://Sprites/GhostBlockB.png")      # Blink texture
@export var smile_texture: Texture2D = load("res://Sprites/GhostBlockS.png")      # Smile texture
@export var ouch_texture: Texture2D = load("res://Sprites/GhostBlockOw.png")	  # Ouch texture
@export var blush_texture: Texture2D = load("res://Sprites/GhostBlockBlush.png")  # Blush texture
var ouched: bool = false

# State variables
var player_in_sight: bool = false  # Tracks if the player is within sight range
var player_dropping: bool = false  # Tracks if the player is in a dropping state
var player_landing: bool = false   # Tracks if the player has landed on the block
var animation_priority: String = "none"  # Current priority animation (blush, ouch)

# This function is called when the scene is ready
func _ready() -> void:
	var sight := $Sight
	# Connect the timer's timeout signal
	timer.timeout.connect(_on_timer_timeout)
	
	# Connect the Area2D signals
	sight.body_entered.connect(_on_player_enter_sight)
	sight.body_exited.connect(_on_player_exit_sight)

	# Start with a neutral face and set an initial random timer
	_reset_and_start_timer()

# Function to reset the timer with a random wait time
func _reset_and_start_timer() -> void:
	if animation_priority == "none":  # Only reset if no priority animation is playing
		timer.wait_time = randf_range(3.0, 6.0)
		timer.start()

# Called when the timer times out (for idle animations)
func _on_timer_timeout() -> void:
	if animation_priority == "none":  # Only play idle animations if no priority animation is playing
		var random_value = randf()
		if random_value < 0.9:
			_play_blink_animation()  # 90% chance
		else:
			_play_smile_animation()  # 10% chance

func _play_blink_animation() -> void:
	sprite.texture = blink_texture
	await get_tree().create_timer(0.5).timeout
	sprite.texture = neutral_texture
	_reset_and_start_timer()

func _play_smile_animation() -> void:
	sprite.texture = smile_texture
	await get_tree().create_timer(1.0).timeout
	sprite.texture = neutral_texture
	_reset_and_start_timer()

# Function to play the 'blush' animation (when player is dropping)
func _play_blush_animation() -> void:
	animation_priority = "blush"
	sprite.texture = blush_texture
	# Don't reset the timer, keep this animation active until the state changes

# Function to play the 'ouch' animation (when player lands)
func _play_ouch_animation() -> void:
	animation_priority = "ouch"
	sprite.texture = ouch_texture
	$Animation.play("Slam")
	await get_tree().create_timer(1.0).timeout  # Ouch lasts for 1 second
	sprite.texture = neutral_texture
	animation_priority = "none"  # Clear the priority after ouch ends
	_reset_and_start_timer()

# Detect when the player enters the sight range
func _on_player_enter_sight(body: Node) -> void:
	if body.name == "Ghost":
		player_in_sight = true
		body.connect("state", Callable(self, "_on_player_state_changed"))  # Connect to player's state signal

# Detect when the player exits the sight range
func _on_player_exit_sight(body: Node) -> void:
	if body.name == "Ghost":
		player_in_sight = false
		body.disconnect("state", Callable(self, "_on_player_state_changed"))  # Disconnect from player's state signal
		if animation_priority == "blush":
			animation_priority = "none"  # Clear blush priority if player leaves
			sprite.texture = neutral_texture
			_reset_and_start_timer()

# Callback for player state changes (connected from the player script)
func _on_player_state_changed(new_state: String) -> void:
#	if new_state == "drop" and player_in_sight:
#		player_dropping = true
#		_play_blush_animation()
	if new_state == "land" and player_in_sight:
		player_landing = true
		if ouched == false:
			_play_ouch_animation()
			ouched = true
		else:
			pass
	if new_state != "land":
		ouched = false
		
	
	else:
		player_dropping = false
		player_landing = false
		if animation_priority == "blush":
			animation_priority = "none"  # Clear blush priority when drop state ends
			sprite.texture = neutral_texture
			_reset_and_start_timer()
