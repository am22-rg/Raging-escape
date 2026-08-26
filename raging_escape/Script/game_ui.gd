extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
	# Connect the signal manager signals for play and pause
	SignalManager.pause_game.connect(_game_paused)
	SignalManager.play_game.connect(_game_playing)
	


# Hide self when the game is playing again
func _game_playing():
	self.show()


# Show self when the game is puased
func _game_paused():
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pause_pressed() -> void:
	SignalManager.pause_game.emit()
