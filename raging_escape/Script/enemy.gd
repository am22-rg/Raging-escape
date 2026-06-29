class_name Enemy
extends CharacterBody2D

@onready var attack_area = $AttackArea

@export var timer_attack: Timer

@export var max_health: int = 0
@export var damage: int = 0
@export var speed: float = 0.0

var player
var health: int
var can_attack: bool = true
var is_colliding: bool = false

#func take_damage(amount: int):
	#health -= amount

	#if health <= 0:
		#die()
#
##func _deal_damage(player):
	##player.take_damage(damage)
#
#func die():
	#queue_free()
	
func _ready():
	health = max_health
	
	# Connecting all the functions
	timer_attack.timeout.connect(_on_attack_timer_timeout)
	
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.area_exited.connect(_on_attack_area_exited)
	print("connected")
	
	
	add_to_group("enemy")
	if self.is_in_group("enemy"):
		print("Working")


func _on_attack_timer_timeout():
	can_attack = true
	
	if is_colliding:
		_attack()
	
func _attack():
	player.take_damage(damage)
	
	can_attack = false
	timer_attack.start()

func _on_attack_area_entered(area):
	if area.is_in_group("player") and can_attack == true:
		is_colliding = true
		player = area.get_parent() 
		_attack()

func _on_attack_area_exited(area):
	if area.is_in_group("player"):
		is_colliding = false
