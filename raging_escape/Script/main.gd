extends Node2D

var current_level: int = 0

@export var max_health = 12

#region UI & External Nodes Var System
@export var camera: Camera2D 
@export var player: CharacterBody2D 

@export var label: Label
@export var menu_ui: Control 
@export var pause_ui: Control 
@export var game_ui: Control 
#endregion

#region Corruption & Screen Shake Var System
# Varibles for corruption
const MULTI_POWER: int = 2
var corruption_val: float = 0

@export var corruption_multiplier := 4.2

# Varibles for screen shake
var noise := FastNoiseLite.new()
var noise_time: float = 0.0
var start_time = Time.get_ticks_msec()

@export var shake_speed: float = 4
@export var max_offset: Vector2 = Vector2(5, 3)
#endregion


func _ready() -> void:
	get_tree().paused = true
	
	# Get the speed of the shake and seed variation
	noise.seed = randi()
	const NOISE_FREQUENCY = 0.5
	noise.frequency = NOISE_FREQUENCY
	
	# Get a connection to the signal manager for screen shake 
	SignalManager.corruption_sig.connect(_update_corruption)
	
	SignalManager.play_game.connect(_game_running)
	SignalManager.pause_game.connect(_game_paused)
	
	SignalManager.reset.connect(_reset_level)
	SignalManager.to_menu.connect(_to_menu)
	
	# Gets the current level
	menu_ui.send_level.connect(_get_current_level)


func _process(delta):
	# Send the reset signal when R is pressed
	if Input.is_action_just_pressed("Reset"):
		SignalManager.reset.emit()
	
	# Make camera shake 
	if corruption_val > 0:
		noise_time += delta * shake_speed
		
		# Make the amount scale as an exponent of 2
		var amount = pow((corruption_val * corruption_multiplier), MULTI_POWER) 
		const NOISE_TIME_OFFSET = 300
		
		# Offset the camera using a Vector 2D
		camera.offset = Vector2(
			noise.get_noise_1d(noise_time) * max_offset.x * amount,
			noise.get_noise_1d(noise_time + NOISE_TIME_OFFSET) * max_offset.y * amount
			)
	else:
		# Otherwise no offset
		camera.offset = Vector2.ZERO
	
	# Get the elapsed time
	var elapsed_time = Time.get_ticks_msec() - start_time
	
	# Make and update all the values for the label
	var mins = elapsed_time / 60000
	var secs = (elapsed_time / 1000) % 60
	var mili_secs = (elapsed_time % 1000) / 10
	label.text = "%02d : %02d : %02d" % [mins, secs, mili_secs]


# Runs when the main menu is opening
func _to_menu():
	# Pause game engine
	get_tree().paused = true
	
	# Show the menu
	menu_ui.show()
	
	# Hide the game ui
	pause_ui.hide()
	game_ui.hide()
	player.hide()
	
	# Remove the current level
	menu_ui.level_select()
	
	# Make sure that only the menu ui is taking input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_reset_stopwatch()


# Reset the stopwatch to 0
func _reset_stopwatch():
	start_time = Time.get_ticks_msec()


# Connected signal to update the corruption
func _update_corruption(corruption):
	corruption_val = corruption


#region Level System
# Resets the level so by deleting and loading the level 
func _reset_level():
	# Pause game and reset the stopwatch
	_game_paused()
	_reset_stopwatch()
	
	# Reset the corruption and player health
	SignalManager.corruption_sig.emit(0)
	player.player_health = player.max_health
	
	# Get the current level and load it
	menu_ui.level_select()
	menu_ui.load_level_id(current_level)


# connected signal to get the current level number
func _get_current_level(level):
	current_level = level
#endregion


#region Pause & Play System
# When the game is paused
func _game_paused():
	get_tree().paused = true
	pause_ui.show()
	
	
	# When the puase menu is open the menu doesn't take input
	pause_ui.mouse_filter = Control.MOUSE_FILTER_STOP


# When the game is running
func _game_running():
	# Pause the game engine
	get_tree().paused = false
	
	# Hide the ui for menu and pause
	menu_ui.hide()
	pause_ui.hide()
	
	# When the game is running the ui doesn't take input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
#endregion
