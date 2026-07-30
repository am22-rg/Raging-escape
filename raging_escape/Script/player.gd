extends CharacterBody2D

var health: int = 12 
var health_regen := 0.2
var enemys_in_range := []
var attack_damage: int = 1
var corruption_val: float = 0
var corruption_equaliser := -0.01

const LEFT := -PI
const RIGHT := 0

const SPEED = 250.0
const JUMP_VELOCITY = -500.0


@onready var timer: Timer = $Timer


@export var health_bar_ui: ProgressBar
@export var Corrution_bar_ui: ProgressBar
@export var ui: Control
@export var attack_box : Area2D


func _ready() -> void:
	ui.connect("pause_game", pause_game)
	ui.connect("unpause_game", unpause_game)


#TODO Health - add the code for the corruptionbar once corruption signal exists
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0:
		attack_box.rotation = RIGHT
	elif velocity.x < 0:
		attack_box.rotation = LEFT
	
	move_and_slide()


# TODO add knock back on hit
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		for enemy in enemys_in_range:
			enemy.take_damage(attack_damage)


func corruption(corruption_add):
	if corruption_val < 0:
		corruption_val = 0
	elif corruption_val > 1:
		corruption_val = 1
	else:
		corruption_val += corruption_add
	Corrution_bar_ui.value = corruption_val
	#SignalManager.corruption_global.emit(corruption_val)


func _on_timer_timeout():
	corruption(corruption_equaliser)
	update_health(health_regen)


func take_damage(damage):
	if health > 1:
		update_health(damage)
	else:
		pass
		# TODO Menu - make a you died menu


func update_health(change):
	health += change
	health_bar_ui.value = health


func pause_game():
	self.hide()


func unpause_game():
	self.show()


func _on_attack_box_body_entered(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.append(body)


func _on_attack_box_body_exited(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.erase(body)
