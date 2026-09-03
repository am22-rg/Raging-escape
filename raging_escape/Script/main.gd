extends Node2D

# Varibles for corruption
var multi_power: int = 2
var corruption_val: float = 0


var noise := FastNoiseLite.new()
var noise_time: float = 0.0

# Varible for the stopwatch
var start_time = Time.get_ticks_msec()

# Varible that plays when a level first opens
var first_play: bool = true

var current_level: int = 0

@onready var label: Label = $CanvasLayer/GameUI/Label
@onready var menu_ui: Control = $CanvasLayer/Menu
@onready var pause_ui: Control = $CanvasLayer/PauseMenu
@onready var game_ui: Control = $CanvasLayer/GameUI
@onready var player: CharacterBody2D = $Player

@onready var camera: Camera2D = $Camera2D

@export var shake_speed: float = 4
@export var corruption_multiplier := 5
@export var max_offset: Vector2 = Vector2(5, 3)



func _ready() -> void:
	get_tree().paused = true
	
	# Get the speed of the shake and seed variation
	noise.seed = randi()
	noise.frequency = 0.5
	
	# Get a connection to the signal manager for screen shake 
	SignalManager.corruption_sig.connect(_update_corruption)
	
	SignalManager.play_game.connect(_game_running)
	SignalManager.pause_game.connect(_game_puased)
	
	SignalManager.reset.connect(_reset_level)
	SignalManager.to_menu.connect(_to_menu)
	
	SignalManager.died.connect(_player_died)
	
	menu_ui.send_level.connect(_get_current_level) # Gets the current level


# Reset the game after the player dies
func _player_died():
	# Reset the corruption 
	SignalManager.corruption_sig.emit(0)
	
	player.health = 12

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
	# TODO redundent/can remove once the backround for menu ui is there
	menu_ui.level_select()
	
	# Make sure that only the menu ui is taking input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_reset_timer()


func _game_puased():
	get_tree().paused = true
	pause_ui.show()
	
	
	# When the puase menu is open the menu doesn't take input
	pause_ui.mouse_filter = Control.MOUSE_FILTER_STOP

func _game_running():
	# Pause the game engine
	get_tree().paused = false
	
	
	# Hide the ui for menu and pause
	menu_ui.hide()
	pause_ui.hide()
	
	# When the game is running the ui doesn't take input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	# Send the reset signal when R is pressed
	if Input.is_action_just_pressed("Reset"):
		SignalManager.reset.emit()
	
	# Make camera shake 
	if corruption_val > 0:
		noise_time += delta * shake_speed
		
		# Make the amount scale as an exponent of 2
		var amount = pow((corruption_val * corruption_multiplier), multi_power) 
		
		# Offset the camera using a Vector 2D
		camera.offset = Vector2(
			noise.get_noise_1d(noise_time) * max_offset.x * amount,
			noise.get_noise_1d(noise_time + 200) * max_offset.y * amount
			)
	else:
		# Otherwise no offset
		camera.offset = Vector2.ZERO
	
	# Get the elapsed time
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Make and update all the values for the label
	var mins = elapsed / 60000
	var secs = (elapsed / 1000) % 60
	var mili_secs = (elapsed % 1000) / 10
	label.text = "%02d : %02d : %02d" % [mins, secs, mili_secs]


# Resets the level so by deleting and loading the level 
func _reset_level():
	_game_puased()
	_reset_timer()
	
	menu_ui.level_select()
	menu_ui.load_level_id(current_level)

# connected signal to get the current level number
func _get_current_level(level):
	current_level = level


# Reset the stopwatch to 0
func _reset_timer():
	start_time = Time.get_ticks_msec()


# Connected signal to update the corruption
func _update_corruption(corruption):
	corruption_val = corruption
