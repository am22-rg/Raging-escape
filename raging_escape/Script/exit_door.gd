extends Area2D

const WAIT_TO_PAUSE: float = 0.1
const WAIT_TO_EXIT: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	#SignalManager.pause_game.connect(_game_paused)
	SignalManager.play_game.connect(_game_running)


# When the player reaches the door
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Pause game and wait so the player knows they reached the end
		await get_tree().create_timer(WAIT_TO_PAUSE).timeout
		get_tree().paused = true
		await get_tree().create_timer(WAIT_TO_EXIT).timeout
		
		# Send signal to update the current_level and go to menu
		SignalManager.to_menu.emit()
		# Check if a new level has been completed
		SignalManager.level_complete.emit(SignalManager.current_level)



#region Pause & Play System
func _game_paused():
	hide()


func _game_running():
	show()
#endregion
