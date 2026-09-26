class_name Enemy
extends CharacterBody2D


#region Movement Var System
var move := false
var direction: float = 0

@export var speed := 100
@export var move_range: Area2D
#endregion

#region Health & Damage Var System
# Health
var enemy_health: int

@export var max_health: int = 0

# Damage
var can_attack: bool = true
var in_range: bool = false

@export var damage: int = 1
@export var attack_area: Area2D
@export var timer_attack: Timer
#endregion

#region Knockback Var System
const ENEMY_WEIGHT: float = 0.035
const KNOCKBACK_POWER: int = 250
const KNOCKUP_POWER: int = -70
#endregion

#region Exports
@export var player: CharacterBody2D

@export var enemy_animation: AnimatedSprite2D
#endregion 


#region Built-in Systems
func _ready():
	self.hide()
	
	# Make health max_health 
	enemy_health = max_health
	
	# Connect all nodes
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.area_exited.connect(_on_attack_area_exited)
	
	timer_attack.timeout.connect(_on_attack_timer_timeout)
	
	# Connect all the signals
	SignalManager.pause_game.connect(_pause_game)
	SignalManager.play_game.connect(_play_game)


func _physics_process(delta):
	# Make the enemy fall when off floor
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# If the player has location and can move
	if not player == null and move == true:
		# Find the direction for the enemy to move in
		direction = signi(player.global_position.x - global_position.x)
		# Move the enemy 
		# Lerp makes it possible for the enemy to have knockback
		# Lerp smooths the velocity back to direction * speed from velocity
		velocity.x = lerp(velocity.x, direction * speed, ENEMY_WEIGHT) 
	else:
		velocity.x = 0
	
	if direction > 0:
		enemy_animation.flip_h = false
	elif direction < 0:
		enemy_animation.flip_h = true
	
	_enemy_animation()
	move_and_slide()
#endregion


#region Movement System
# If out of sight makes the enemy stop moving
func _on_move_range_exited(area):
	if area.is_in_group("player"):
		player = null
		move = false


# If in sight makes the enemy move
func _on_move_range_entered(area):
	if area.is_in_group("player"):
		player = area.get_parent()
		move = true


func _enemy_animation():
	if velocity.x != 0 and is_on_floor():
		enemy_animation.play("run")
	elif not is_on_floor():
		enemy_animation.play("in_air")
	else:
		enemy_animation.play("idle")
#endregion 


#region Health System
func take_damage(damage):
	# Make the enemy take damage 
	enemy_health -= damage
	
	# Set knockback values
	velocity.x = KNOCKBACK_POWER * -direction * damage
	velocity.y = KNOCKUP_POWER
	
	# If the enemy has no health die
	if enemy_health <= 0:
		_die()

# When the enemy dies
func _die():
	# Create a range corruption will increase by when the enemy dies
	const CORRUPTION_MIN_RANGE = 0.1
	const CORRUPTION_MAX_RANGE = 0.25
	var corruption = randf_range(CORRUPTION_MIN_RANGE, CORRUPTION_MAX_RANGE)
	
	# Send the new corruption value
	SignalManager.corruption_sig.emit(player.corruption_val + corruption)
	
	queue_free()
#endregion 


#region Attack System
# Tells the enemy the player is in attackbox
func _on_attack_area_entered(area):
	if area.is_in_group("player") and can_attack == true:
		in_range = true
		player = area.get_parent()
		
		# Attacks player 
		_attack()


# Checks if the player has exited the enemy attack box
func _on_attack_area_exited(area):
	if area.is_in_group("player"):
		in_range = false


# Attacks player
func _attack():
	# Update the players health
	player.update_health(damage)
	
	# sets a timer for when the enemy can attack again
	can_attack = false
	timer_attack.start()


# Allows the enemy to attack again
func _on_attack_timer_timeout():
	can_attack = true
	
	# The enemy attacks again if still touching the player
	if in_range:
		_attack()
#endregion 


#region Pause & Play System
# In cuase I need it
func _pause_game():
	pass


#show the enemy when the game is running
func _play_game():
	self.show()
#endregion 
