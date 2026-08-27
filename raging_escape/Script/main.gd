extends Node2D

var multi_power: int = 2
var corruption_val: float = 0

var noise := FastNoiseLite.new()
var noise_time: float = 0.0

var start_time = Time.get_ticks_msec()

var first_play: bool = true

@onready var label: Label = $CanvasLayer/GameUI/Label
@onready var menu_ui: Control = $CanvasLayer/Menu
@onready var pause_ui: Control = $CanvasLayer/PauseMenu
@onready var game_ui: Control = $CanvasLayer/GameUI

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
	SignalManager.corruption_sig.connect(update_corruption)
	SignalManager.play_game.connect(_game_running)
	SignalManager.pause_game.connect(_game_puased)
	SignalManager.to_menu.connect(_to_menu)


func _to_menu():
	first_play = true
	
	# Pause game engine
	get_tree().paused = true
	
	# Show the menu
	menu_ui.show()
	
	# Hide the game ui
	pause_ui.hide()
	game_ui.hide()
	
	# Remove the current level
	# TODO redundent/can remove once the backround for menu ui is there
	menu_ui.level_select()
	
	# Make sure that only the menu ui is taking input
	menu_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Reset the stopwatch to 0
	start_time = Time.get_ticks_msec()


func _game_puased():
	get_tree().paused = true
	pause_ui.show()
	
	if first_play == true:
		first_play = false
		
		camera.position = Vector2.ZERO
	
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
	# Get the elapsed time
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Make and update all the values for the label
	var mins = elapsed / 60000
	var secs = (elapsed / 1000) % 60
	var mili_secs = (elapsed % 1000) / 10
	label.text = "%02d : %02d : %02d" % [mins, secs, mili_secs]
	
	
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
	
	if Input.is_action_just_pressed("Reset"):
		_game_puased()
		menu_ui.level_select()
		menu_ui.show()


func update_corruption(corruption):
	corruption_val = corruption
