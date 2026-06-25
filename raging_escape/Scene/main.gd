extends Node2D

signal reset
@export var ui: Control


func _ready() -> void:
	ui.connect("pause_game", pause_game)
	ui.connect("unpause_game", unpause_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()
		ui.level_select()
		ui.show()


func pause_game() -> void:
	print("pausing")
	get_tree().paused = true
	ui.show()


func unpause_game() -> void:
	print("unpausing")
	get_tree().paused = false
	ui.hide()
