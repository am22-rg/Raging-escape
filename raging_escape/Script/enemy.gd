class_name Enemy
extends CharacterBody2D

@onready var attack_area = $Area2D

@export var timer_attack: Timer

func _ready():
	attack_area.body_entered.connect(_on_area_2d_body_entered)
	add_to_group("enemy")
	if self.is_in_group("enemy"):
		print("Working")


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"): #add and timer 
		print("collision")
