extends Node2D

signal reset
@onready var ui: Control = $UI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("return"):
		puase_game()
		ui.level_select()
		ui.show()


func puase_game() -> void:
	print("puasing")
	get_tree().paused = true
	ui.show()

func unpuase_game() -> void:
	get_tree().paused = false
	ui.hide()
