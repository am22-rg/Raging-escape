class_name Enemy
extends CharacterBody2D

@onready var attack_area = $AttackArea
@onready var move_range = $MoveRange
@onready var player = $"."

@export var timer_attack: Timer

@export var max_health: int = 0
@export var damage: int = 1

@export var direction = true
@export var speed := 100

var move := false
var health: int
var can_attack: bool = true
var in_range: bool = false


func _ready():
	self.hide()
	
	health = max_health
	
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.area_exited.connect(_on_attack_area_exited)
	
	timer_attack.timeout.connect(_on_attack_timer_timeout)
	
	SignalManager.pause_game.connect(pause_game)
	SignalManager.play_game.connect(play_game)


func pause_game():
	self.hide()

func play_game():
	self.show()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not player == null and move == true:
		var direction := signi(player.global_position.x - global_position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0
	move_and_slide()


func _on_move_range_exited(area):
	if area.is_in_group("player"):
		player = null
		move = false


func _on_move_range_entered(area):
	if area.is_in_group("player"):
		player = area.get_parent()
		move = true

func _on_attack_timer_timeout():
	can_attack = true
	
	if in_range:
		_attack()


func _attack():
	player.update_health(damage)
	
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
	var corruption = randf_range(0.1, 0.25)
	player.corruption(corruption)
	queue_free()
