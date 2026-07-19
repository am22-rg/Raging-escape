class_name Enemy
extends CharacterBody2D

@onready var attack_area = $AttackArea

@export var timer_attack: Timer

@export var max_health: int = 5
@export var damage: int = 0
@export var speed: float = 0.0

var player
var health: int
var can_attack: bool = true
var in_range: bool = false


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


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta



func _on_attack_timer_timeout():
	can_attack = true
	
	if in_range:
		_attack()


func _attack():
	print("Attack")
	player.take_damage(damage)
	
	can_attack = false
	timer_attack.start()


func _on_attack_area_entered(area):
	if area.is_in_group("player") and can_attack == true:
		in_range = true
		player = area.get_parent() 
		_attack()


func _on_attack_area_exited(area):
	if area.is_in_group("player"):
		in_range = false
		

# TODO - Add direction and knockback
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()


func die():
	queue_free()
