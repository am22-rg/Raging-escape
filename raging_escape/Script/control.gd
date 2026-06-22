extends Control

signal puase_game()
signal unpuase_game()


var levels = {
	1: preload("res://Scene/Levels/level_1.tscn"),
	2: preload("res://Scene/Levels/level_2.tscn"),
}

@onready var level_container = get_parent().get_node("LevelContainer")

var current_level: PackedScene = levels[1] # Current level to check which scene is running
var level_node: Node = null
var level: int = 1
var character: int = 1
var character_skins: int = 1

func _ready() -> void:
	self.show()
	emit_signal("puase_game")


# Change level
func load_level_id(id):
	emit_signal("puase_game")
	self.show()
	if levels.has(id): # Load new scene
		var scene_instance = levels[id].instantiate()
		level_container.add_child(scene_instance) # Adds level under the Level container
		level_node = scene_instance
		current_level = levels[id]
		emit_signal("unpuase_game")
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
