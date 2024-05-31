extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 7

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

var mouseInput : bool = false
var mouseRot : Vector3
var rotInput : float
var tiltInput : float
var horizontalsens : float = 1.0
var verticalsens : float = 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var CameraController = get_node("CameraController")

func _ready():
	Game.playerReady()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	updateCamera(delta)

	move_and_slide()

func updateCamera(delta):
	mouseRot.x += tiltInput * delta * 0.7 * verticalsens
	mouseRot.x = clamp(mouseRot.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRot.y += rotInput * delta * 0.6 * horizontalsens
	
	CameraController.transform.basis = Basis.from_euler(mouseRot)
	CameraController.rotation.y = 0.0
	CameraController.rotation.z = 0.0
	
	transform.basis = Basis.from_euler(mouseRot)
	rotation.x = 0.0
	rotation.z = 0.0
	
	rotInput = 0.0
	tiltInput = 0.0

func _unhandled_input(event):
	mouseInput = !Game.pauseCheck() and event is InputEventMouseMotion
	if mouseInput:
		rotInput = -event.relative.x
		tiltInput = -event.relative.y

func setSens(x,y):
	horizontalsens = x
	verticalsens = y
