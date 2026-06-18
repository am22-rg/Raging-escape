extends Control

var levels = {
	#1: preload(""),
	#2: preload(""),
}
var level: int = 1
var character: int = 1
var character_skins: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO Menu - change character on screen menu
func neg_button_character() -> void:
	if character > 2:
		character -= 1


func pos_button_character() -> void:
	if character < character_skins:
		character += 1


func neg_button_level() -> void:
	if level > 2:
		level -= 1


func pos_button_level() -> void:
	if level < levels:
		level += 1
