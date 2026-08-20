extends Node2D

signal reset

var multi_power: int = 2
var corruption_val: float = 0

var noise := FastNoiseLite.new()
var noise_time: float = 0.0

var start_time = Time.get_ticks_msec()

@onready var label: Label = $CanvasLayer/Label

@export var ui: Control
@export var shake_speed: float = 4
@export var corruption_multiplier := 5
@export var max_offset: Vector2 = Vector2(5, 3)
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	get_tree().paused = true
	ui.connect("pause_game", pause_game)
	ui.connect("unpause_game", unpause_game)
	
	# Get the speed of the shake and seed variation
	noise.seed = randi()
	noise.frequency = 0.5
	
	# Get a connection to the signal manager for screen shake 
	SignalManager.corruption_sig.connect(update_corruption)


func _process(delta):
	# Get the elapsed time
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Make and update all the values for the label
	var mins = elapsed / 6000
	var secs = (elapsed / 1000) % 60
	var mili_secs = (elapsed % 1000) / 10
	label.text = "%02d:%02d:%02d" % [mins, secs, mili_secs]
	
	
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
	
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()
		ui.level_select()
		ui.show()


func update_corruption(corruption):
	corruption_val = corruption


func pause_game() -> void:
	get_tree().paused = true
	ui.show()


func unpause_game() -> void:
	get_tree().paused = false
	ui.hide()
