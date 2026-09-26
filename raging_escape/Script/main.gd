extends Node2D

var current_level: int = 0

@export var max_health = 12

#region UI & External Nodes Var System
# External Nodes
@export var camera: Camera2D 
@export var player: CharacterBody2D 

# UI
@export var label: Label
@export var menu_ui: Control 
@export var pause_ui: Control 
@export var game_ui: Control 
#endregion

#region Corruption & Screen Shake Var System
# Corruption
const MULTI_POWER: int = 2
var corruption_val: float = 0

@export var corruption_multiplier := 4.2

# Screen shake
var noise := FastNoiseLite.new()
var noise_time: float = 0.0
var start_time = Time.get_ticks_msec()

@export var shake_speed: float = 4
@export var max_offset: Vector2 = Vector2(5, 3)
#endregion


#region Built-in Systems
func _ready() -> void:
	# Keep everthing in position before the game starts
	get_tree().paused = true
	
	# Get the speed of the shake and seed variation
	const NOISE_FREQUENCY = 0.5
	
	noise.seed = randi()
	noise.frequency = NOISE_FREQUENCY
	
	# Connect all signals
	SignalManager.corruption_sig.connect(_update_corruption)
	
	SignalManager.play_game.connect(_game_running)
	SignalManager.pause_game.connect(_game_paused)
	
	SignalManager.reset.connect(_reset_level)
	SignalManager.to_menu.connect(_to_menu)


func _process(delta):
	# Send the reset signal when R is pressed
	if Input.is_action_just_pressed("Reset"):
		SignalManager.reset.emit()
	
	# Make camera shake 
	if corruption_val > 0:
		noise_time += delta * shake_speed
		
		# Make the amount scale as an exponent of 2
		var amount = pow(corruption_val * corruption_multiplier, MULTI_POWER) 
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
	
	# Make and update all the values for the stopwatch
	var mins = elapsed_time / 60000
	var secs = (elapsed_time / 1000) % 60
	var mili_secs = (elapsed_time % 1000) / 10
	label.text = "%02d : %02d : %02d" % [mins, secs, mili_secs]
#endregion


#region Reset & Navigation
# Runs when the main menu is opening
func _to_menu():
	# Pause game engine
	get_tree().paused = true
	
	# Show the menu
	menu_ui.show()
	
	# Hide the other ui
	pause_ui.hide()
	game_ui.hide()
	
	# Reset the corruption and player health
	SignalManager.corruption_sig.emit(0)
	player.player_health = player.max_health
	
	# Make sure that only the menu ui is taking input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Remove the current level
	menu_ui.level_select()
	
	# Reset the stopwatch
	_reset_stopwatch()


# Resets the level so by deleting and loading the level 
func _reset_level():
	# Reset the stopwatch
	_reset_stopwatch()
	
	# Reset the corruption and player health
	SignalManager.corruption_sig.emit(0)
	player.player_health = player.max_health
	
	# Get the current level and load it
	current_level = menu_ui.level_select()
	menu_ui.load_level_id(current_level)


# Reset the stopwatch to 0
func _reset_stopwatch():
	start_time = Time.get_ticks_msec()
#endregion


#region Pause & Play System
# When the game is paused
func _game_paused():
	# Make sure that everything is in postion when the game isn't running
	get_tree().paused = true
	
	# Show the pause menu
	pause_ui.show()
	
	# When the puase menu is open the menu doesn't take input
	pause_ui.mouse_filter = Control.MOUSE_FILTER_STOP


# When the game is running
func _game_running():
	# Play the game so everything can move 
	get_tree().paused = false
	
	# Hide both main menu and pause menu
	menu_ui.hide()
	pause_ui.hide()
	
	# When the game is running the ui doesn't take input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
#endregion


# Connected signal to update the corruption
func _update_corruption(corruption):
	corruption_val = corruption
