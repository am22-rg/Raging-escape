extends Control

@export var menu_ui: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
	# Connect the pause and play signals the the puase menu
	SignalManager.pause_game.connect(_game_running)
	SignalManager.play_game.connect(_game_paused)


# Hide self when the game is playing again
func _game_running():
	self.hide()


# Show self when the game is puased
func _game_paused():
	self.show()


# Play button pressed
func _on_play_pressed() -> void:
	# Emits a signal that the game is playing
	print("emitted")
	SignalManager.play_game.emit() 


func _on_menu_pressed() -> void:
	SignalManager.to_menu.emit()


func _on_reset_pressed() -> void:
	SignalManager.reset.emit()
