extends Node2D

signal reset

var trauma := 0.0
var multi_power: int = 2
var corruption_val

@export var ui: Control

@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(30, 20)
@onready var camera: Camera2D = $Camera2D


func shake():
	trauma * corruption_val
	var amount = pow(trauma, multi_power)
	camera.offset.x = max_offset * amount


func _ready() -> void:
	get_tree().paused = true
	ui.connect("pause_game", pause_game)
	ui.connect("unpause_game", unpause_game)
	
	# Get a connection to the signal manager for screen shake 
	SignalManager.corruption_sig.connect(update_corruption)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()
		ui.level_select()
		ui.show()


func update_corruption():
	pass


func pause_game() -> void:
	get_tree().paused = true
	ui.show()


func unpause_game() -> void:
	get_tree().paused = false
	ui.hide()
