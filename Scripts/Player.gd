extends CharacterBody3D

# Player state.
enum State {
	GROUNDED,
	JUMPING,
	DIVING,
	FALLING
}
var player_state = State.GROUNDED

# Player nodes.
@onready var animations: AnimationPlayer = $Visuals/Model/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var jump_timer: Timer = $JumpTimer
@onready var consecutive_jump_timer: Timer = $ConsecutiveJumpTimer
@onready var dive_timer: Timer = $DiveTimer

# Player properties and variables.
@export var walk_speed: float = 6.0
@export var run_speed: float = 15.0
var current_speed: float = walk_speed
@export var lerp_speed: float = 3

@export var gravity: float = 50
@export var jump_impulse: float = 20.0
@export var long_jump_impulse: float = 70.0
var jumping: bool = false
var long_jumping: bool = false
@export var dive_impulse: float = 50.0
var diving: bool = false
var dive_available: bool = true

# Camera nodes.
@onready var camera_h: Node3D = $CameraH
@onready var camera_v: Node3D = $CameraH/CameraV
@onready var camera: Camera3D = $CameraH/CameraV/SpringArm/Camera

# Camera properties and variables.
@export var mouse_h_sensitivity: float = 10
@export var mouse_v_sensitivity: float = 10
var yaw: float = 0.0 # Rotation around Y-axis.
var pitch: float = 0.0 # Rotation around X-axis.

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

# Execute camera movement.
func _process(delta: float):
	if(is_on_floor() and !dive_available): dive_available = true
	if(is_on_floor() and long_jumping): long_jumping = false
	camera_movement(delta)
	animate()

# Register mouse and exit input.
func _input(event: InputEvent):
	# Store mouse movement.
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_h_sensitivity
		pitch -= event.relative.y * mouse_v_sensitivity

	if event.is_action("Exit"): get_tree().quit()

# Physics movements (Move, Jump, Dive).
func _physics_process(delta: float):
	# Execute body movement.
	body_movement(delta)
	
	if Input.is_action_just_pressed("Jump") and Input.is_action_pressed("Crouch") and is_on_floor(): long_jump()
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and !long_jumping: jump()
	
	if Input.is_action_just_pressed("Dive") and !is_on_floor() and dive_available and !long_jumping: dive()
	
	if Input.is_action_pressed("Crouch") and is_on_floor(): crouch(delta)
	
	if !jumping and !is_on_floor(): velocity.y -= gravity * delta


# Physics function - controls player movement.
func body_movement(delta: float):
	# Capture movement input.
	var input = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction: Vector3 = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	
	# Handle animations and speed.
	if direction:
		if Input.is_action_pressed("Run"):
			current_speed = lerp(current_speed, run_speed, lerp_speed * delta)
		else:
			current_speed = lerp(current_speed, walk_speed, lerp_speed * delta)
		
		# Rotate visuals in walk direction.
		visuals.look_at(position + direction)

		# Update movement velocity.
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# Update velocity to a stop.
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	# Execute movement.
	move_and_slide()
	pass

# Process function - controls camera movement.
func camera_movement(delta: float):
	
	rotate_y(deg_to_rad(yaw) * delta)
	visuals.rotate_y(deg_to_rad(-yaw) * delta)

	camera_v.rotate_x(deg_to_rad(pitch) * delta)
	camera_v.rotation.x = clamp(camera_v.rotation.x, deg_to_rad(-60), deg_to_rad(65))
	
	yaw = 0.0
	pitch = 0.0

func jump():
	jumping = true
	velocity.y = jump_impulse
	jump_timer.start()
	pass

func long_jump():
	long_jumping = true
	velocity.y = jump_impulse * 0.75
	current_speed = long_jump_impulse
	pass

func dive():
	diving = true
	dive_available = false
	current_speed = dive_impulse
	dive_timer.start()
	pass

func crouch(delta: float):
	current_speed = lerp(current_speed, 0.0, lerp_speed * delta)
	pass

func animate():
	if !is_on_floor():
		if long_jumping:
			if animations.current_animation != "LongJump":
				animations.play("LongJump")
		elif diving:
			if animations.current_animation != "Dive":
				animations.play("Dive")
		elif jumping:
			if animations.current_animation != "Jump":
				animations.play("Jump")
		elif !dive_available:
			if animations.current_animation != "Fall2":
				animations.play("Fall2")
		else:
			if animations.current_animation != "Fall":
				animations.play("Fall")
	elif Input.is_action_pressed("Crouch"):
		if animations.current_animation != "Crouch":
			animations.play("Crouch")
	elif Input.is_action_pressed("Run") and Input.is_action_pressed("AnyMovement"):
		if animations.current_animation != "Sprint":
			animations.play("Sprint")
	elif Input.is_action_pressed("AnyMovement"):
		if animations.current_animation != "Run":
			animations.play("Run")
	else:
		if animations.current_animation != "Idle":
			animations.play("Idle")

func _on_jump_timer():
	jumping = false
	pass # Replace with function body.


func _on_dive_timer():
	diving = false
	pass # Replace with function body.
