extends CharacterBody2D

var health: float = max_health
var health_regen := 0.5
var enemys_in_range := []
var attack_damage: int = 1

var dash: int = 3000
var dashes: int = max_dashes
var hang_time := 0.7

var corruption_val: float = 0
var corruption_equaliser := 0.05
var corruption_release: float = 0.15

const LEFT := -PI
const RIGHT := 0

const SPEED = 250.0
const JUMP_VELOCITY = -500.0
var current_speed: float = 250

@export var damage_curve: Curve
@export var speed_curve: Curve

@export var health_bar_ui: ProgressBar
@export var Corrution_bar_ui: ProgressBar
@export var ui: Control

@export var attack_box : Area2D
@export var max_dashes: int 
@export var max_health: int = 12


func _ready() -> void:
	self.hide()
	
	# Connects SignalManager signals needed
	SignalManager.corruption_sig.connect(_corruption)
	SignalManager.pause_game.connect(_pause_game)
	SignalManager.play_game.connect(_play_game)

func _pause_game():
	self.hide()


func _play_game():
	self.show()
	
	# Set the velocity to zero
	velocity = Vector2.ZERO
 

#TODO Health - add the code for the corruptionbar once corruption signal exists
func _physics_process(delta: float) -> void:
	# Get current speed
	var speed_multiplier := speed_curve.sample(corruption_val)
	var current_speed := SPEED * speed_multiplier
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		dashes = max_dashes
		
	# Handle jump.
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("Left", "Right")
	
	if direction:
		velocity.x = direction * current_speed
		
		# lets the player dash then addeds a cool down
		if Input.is_action_just_pressed("Dash"):
			if not is_on_floor() and dashes > 0:
				velocity.x += direction * dash
				dashes -= 1
				velocity -= hang_time * get_gravity() * delta
				print(velocity.y)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
	
	if velocity.x > 0:
		attack_box.rotation = RIGHT
	elif velocity.x < 0:
		attack_box.rotation = LEFT
	
	
	move_and_slide()


# TODO add knock back on hit
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("Attack"):
		damage_multiplier()
	
	if Input.is_action_just_pressed("Release"):
		SignalManager.corruption_sig.emit(corruption_val - corruption_release)


# Made a curve for multiplying damage to deal to enemy based on corruption
func damage_multiplier():
	var damage_multiplier := damage_curve.sample(corruption_val)
	var multiplied_damage := attack_damage * damage_multiplier
	
	for enemy in enemys_in_range:
		enemy.take_damage(multiplied_damage)


func _corruption(corruption):
	# Update the corruption value
	corruption_val = corruption
	
	# Make sure corruption is not more than 1 or less than 0
	if corruption_val < 0:
		corruption_val = 0
		SignalManager.corruption_sig.emit(corruption_val)
	
	elif corruption_val > 1:
		corruption_val = 1
		SignalManager.corruption_sig.emit(corruption_val)

	Corrution_bar_ui.value = corruption_val


func _on_const_timer_timeout():
	SignalManager.corruption_sig.emit(corruption_val - corruption_equaliser)
	update_health(health_regen)


func update_health(change):
	if health >= 1:
		health += change
		
		print(health)
		
		# To insure health cannot excede the limit
		if health >= 12:
			health = 12
		
		print(health)
		
		health_bar_ui.value = health
	else:
		SignalManager.to_menu.emit()
		SignalManager.died.emit()


func _on_attack_box_body_entered(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.append(body)


func _on_attack_box_body_exited(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.erase(body)
