extends Control

signal send_level

var levels = {
	1: preload("res://Scene/Levels/level_1.tscn"),
	2: preload("res://Scene/Levels/level_2.tscn"),
	3: preload("res://Scene/Levels/level_3.tscn"),
	4: preload("res://Scene/Levels/level_4.tscn"),
}

@export var level_label: Label
@export var character_label: Label
@export var player: CharacterBody2D

@onready var level_container: Node2D = $"../../Level Container"

var current_level: PackedScene = levels[1] # Current level to check which scene is running
var level_node: Node = null
var level: int = 1
var character: int = 1
var character_skins: int = 1

# Show the menu at the start of the game
func _ready():
	self.show()


# Open the correct level
func play_button_pressed():
	load_level_id(level)


# Change level
func load_level_id(id):
	self.show()
	if levels.has(id): # Load new scene
		# Make sure the level node is empty
		level_select()
		
		# Instance the level and add it to the level node
		var scene_instance = levels[id].instantiate()
		level_container.add_child(scene_instance)
		level_node = scene_instance
		current_level = levels[id]
		
		# Make sure the player will spawn in the correct position
		player.global_position = Vector2(0, 0)
		
		# Start running the game
		SignalManager.play_game.emit()
		self.hide()


# Find the level number and delete the current level
func level_select():
	self.show()
	
	# Send current level to the game engine
	var level_number := -1
	
	# Find the current level number
	for key in levels:
		if levels[key] == current_level:
			level_number = key
	
	# Send to the game engine
	send_level.emit(level_number)
	
	if is_instance_valid(level_node): # Get rid of current scene
		level_node.queue_free()


func neg_button_level():
	if level > 1:
		level -= 1
		level_label.text = str(level)


func pos_button_level():
	if level < levels.size():
		level += 1
		level_label.text = str(level)
