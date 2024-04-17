extends StaticBody3D

@export var speed: float = 5.0

@export var x_distance: float = 0.0
@export var y_distance: float = 0.0
@export var z_distance: float = 0.0

var x_enabled: bool
var y_enabled: bool = y_distance > 0
var z_enabled: bool = z_distance > 0

var current_x_direction: int = 1
var current_y_direction: int = 1
var current_z_direction: int = 1
var base_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	base_position = position
	x_enabled = x_distance > 0
	y_enabled = y_distance > 0
	z_enabled = z_distance > 0
	pass # Replace with function body.

func _physics_process(delta):
	if abs(base_position.x - position.x) >= x_distance: current_x_direction *= -1
	if abs(base_position.y - position.y) >= y_distance: current_y_direction *= -1
	if abs(base_position.z - position.z) >= z_distance: current_z_direction *= -1
	print(x_distance > 0)
	position += speed * delta * Vector3(\
		int(x_enabled) * current_x_direction, \
		int(y_enabled) * current_y_direction, \
		int(z_enabled) * current_z_direction)
