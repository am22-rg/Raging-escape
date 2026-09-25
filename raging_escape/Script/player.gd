extends CharacterBody2D

#region Health Var Sytem
const HEALTH_REGEN := 0.5

var player_health: float = 0
var enemys_in_range := []

@export var attack_box : Area2D
@export var max_health: int = 12
#endregion

#region Dash & Jump Var System
# Dash  
const DASH_DIS: int = 3000
var dashes: int = max_dashes

@export var max_dashes: int 

# Coyote time
var coyote_time: float = 0.0

@export var max_coyote_time: float 
#endregion

#region Corruption Var System
var corruption_val: float = 0
const CORRUPTION_EQUALISER := 0.05
const CORRUPTION_RELEASE: float = 0.15
#endregion

#region Movement Var System
# Handles rotaion of the player
const LEFT := -PI
const RIGHT := 0

const SPEED = 180.0
const JUMP_VELOCITY = -500.0
var current_speed: float = 250
#endregion

#region Curves
@export var damage_curve: Curve
@export var speed_curve: Curve
#endregion

#region UI
@export var health_bar_ui: ProgressBar
@export var Corrution_bar_ui: ProgressBar
@export var ui: Control
#endregion


func _ready() -> void:
	self.hide()
	
	# Make health max health at the start of the game
	player_health = max_health
	
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
 

func _physics_process(delta: float) -> void:
	# Get current speed
	var speed_multiplier := speed_curve.sample(corruption_val)
	var current_speed := SPEED * speed_multiplier
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# Timer counts down in the air
		coyote_time -= delta
	else:
		# Reset the dashes
		dashes = max_dashes
		
		# Reset the coyote time
		coyote_time = max_coyote_time
		
	# Handle jump.
	if Input.is_action_just_pressed("Up") and coyote_time > 0:
		velocity.y = JUMP_VELOCITY
		
		# So the player cant jump again
		# Im keeping this commented for now
		# Becuase its actually better more movement complexity
		#coyote_time = 0
	
	var direction := Input.get_axis("Left", "Right")
	
	# When the player is moving
	if direction:
		velocity.x = direction * current_speed
		
		# lets the player dash then addeds a cool down
		if Input.is_action_just_pressed("Dash"):
			if not is_on_floor() and dashes > 0:
				velocity.x += direction * DASH_DIS
				dashes -= 1
				velocity -= get_gravity() * delta
	else:
		velocity.x = 0
	
	# Changing the direction the player is facing when its moving
	if velocity.x > 0:
		attack_box.rotation = RIGHT
	elif velocity.x < 0:
		attack_box.rotation = LEFT
	
	move_and_slide()


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("Attack"):
		damage_multiplier()
	
	if Input.is_action_just_pressed("Release"):
		SignalManager.corruption_sig.emit(corruption_val - CORRUPTION_RELEASE)


# Made a curve for multiplying damage to deal to enemy based on corruption
func damage_multiplier():
	const ATTACK_DAMAGE: int = 1
	var damage_multiplier := damage_curve.sample(corruption_val)
	var multiplied_damage := ATTACK_DAMAGE * damage_multiplier
	
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
	SignalManager.corruption_sig.emit(corruption_val - CORRUPTION_EQUALISER)
	update_health(HEALTH_REGEN)


func update_health(change):
	if player_health >= 1:
		player_health += change
		
		# To insure health cannot excede the limit
		if player_health >= max_health:
			player_health = max_health
		
		health_bar_ui.value = player_health
	else:
		SignalManager.to_menu.emit()
		SignalManager.corruption_sig.emit(0)
		
		player_health = max_health


func _on_attack_box_body_entered(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.append(body)


func _on_attack_box_body_exited(body: Node2D):
	if body.is_in_group("enemy"):
		enemys_in_range.erase(body)
