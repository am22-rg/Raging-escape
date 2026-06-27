extends Control

signal pause_game
signal unpause_game


var levels = {
	1: preload("res://Scene/Levels/level_1.tscn"),
	2: preload("res://Scene/Levels/level_2.tscn"),
	3: preload("res://Scene/Levels/level_3.tscn"),
	4: preload("res://Scene/Levels/level_4.tscn"),
}

@export var level_label: Label
@export var character_label: Label

@onready var level_container: Node2D = $"../../Level Container"

var current_level: PackedScene = levels[1] # Current level to check which scene is running
var level_node: Node = null
var level: int = 1
var character: int = 1
var character_skins: int = 1

func _ready() -> void:
	self.show()
	pause_game.emit()


# Change level
func load_level_id(id):
	pause_game.emit()
	self.show()
	if levels.has(id): # Load new scene
		level_select()
		var scene_instance = levels[id].instantiate()
		level_container.add_child(scene_instance) # Adds level under the Level container
		level_node = scene_instance
		current_level = levels[id]
		emit_signal("unpause_game")
		self.hide()


func level_select():
	self.show()
	if is_instance_valid(level_node): # Get rid of current scene
		level_node.queue_free()


# Open the correct level
func play_button_pressed() -> void:
	load_level_id(level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO Menu - change character on screen menu
func neg_button_character() -> void:
	if character > 1:
		character -= 1
		character_label.text = str(character)


func pos_button_character() -> void:
	if character < character_skins:
		character += 1
		character_label.text = str(character)


func neg_button_level() -> void:
	if level > 1:
		level -= 1
		level_label.text = str(level)


func pos_button_level() -> void:
	if level < levels.size():
		level += 1
		level_label.text = str(level)
