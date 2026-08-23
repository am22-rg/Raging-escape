extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the pause and play signals the the puase menu
	SignalManager.pause_game.connect(_game_playing)
	SignalManager.play_game.connect(_game_paused)
	
	self.hide()


# Hide self when the game is playing again
func _game_playing():
	self.hide()


# Show self when the game is puased
func _game_paused():
	self.show()


# Play button pressed
func _on_play_pressed() -> void:
	# Emits a signal that the game is playing
	SignalManager.play_game.emit() 


func _on_menu_pressed() -> void:
	pass # Replace with function body.


func _on_reset_pressed() -> void:
	pass # Replace with function body.
