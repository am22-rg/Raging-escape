extends Control

signal send_level

# External varibles
@export var player: CharacterBody2D
@export var tutorial_menu: Control 

#region Level Var System
var level_dict = {
	1: preload("res://Scene/Levels/level_1.tscn"),
	2: preload("res://Scene/Levels/level_2.tscn"),
	3: preload("res://Scene/Levels/level_3.tscn"),
	4: preload("res://Scene/Levels/level_4.tscn"),
}

# Current level to check which scene is running
var current_level: PackedScene = level_dict[1]
var level_node: Node = null
var level: int = 1

@export var level_label: Label
@export var level_container: Node2D 
#endregion

# Show the menu at the start of the game
func _ready():
	self.show()
	tutorial_menu.hide()


# Open the correct level
func play_button_pressed():
	load_level_id(level)


#region Level System
# Change level
func load_level_id(id):
	self.show()
	
	# Load new scene
	if level_dict.has(id):
		# Make sure the level node is empty
		level_select()
		
		# Instance the level and add it to the level node
		var scene_instance = level_dict[id].instantiate()
		level_container.add_child(scene_instance)
		level_node = scene_instance
		current_level = level_dict[id]
		
		# Make sure the player will spawn in the correct position
		player.global_position = Vector2.ZERO
		
		# Start running the game
		SignalManager.play_game.emit()
		self.hide()


# Find the level number and delete the current level
func level_select():
	self.show()
	
	# Make a current level number that is false
	var level_number := -1
	
	# Find the current level number
	for key in level_dict:
		if level_dict[key] == current_level:
			level_number = key
	
	# Get rid of current scene
	if is_instance_valid(level_node):
		level_node.queue_free()
	
	# Send the current level to the game engine
	return level_number
#endregion


# Buttons for selecting level using a counter
#region Level Buttons
func neg_button_level():
	if level > 1:
		level -= 1
		level_label.text = str(level)


func pos_button_level():
	if level < level_dict.size():
		level += 1
		level_label.text = str(level)
#endregion


# Buttons hold to open or close tutorial screen
#region Tutorial Buttons
func _on_tutorial_button_up() -> void:
	tutorial_menu.hide()


func _on_tutorial_button_down() -> void:
	tutorial_menu.show()
#endregion
