extends CharacterBody2D

var health: int = 12 


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@export var health_bar_ui: ProgressBar
@export var Corrution_bar_ui: ProgressBar
@export var ui: Control


func _ready() -> void:
	ui.connect("pause_game", pause_game)
	ui.connect("unpause_game", unpause_game)


func Take_damage():
	if health > 1:
		health -= 1
		health_bar_ui.value = health
	else:
		pass
		# TODO Menu - make a you died menu

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

	move_and_slide()



func pause_game() -> void:
	set_physics_process(false)
	self.hide()


func unpause_game() -> void:
	set_physics_process(true)
	self.show()
