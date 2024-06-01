extends CharacterBody3D


const SPEED = 4.0
const SPRINT_MULT = 1.5
const JUMP_VELOCITY = 7

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

var mouseInput : bool = false
var sprinting : bool = false
var mouseRot : Vector3
var rotInput : float
var tiltInput : float
var horizontalsens : float = 1.0
var verticalsens : float = 1.0

var holdingPrimary : bool = true
var holdingHeavy : bool = false
var primary
var secondary
var heavy

var DEV_pos : Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var CameraController = get_node("CameraController")

func _ready():
	Game.playerReady()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	pointGun()
	move(delta)
	updateCamera(delta)
	
	move_and_slide()

func fireHeldGun():
	if holdingHeavy:
		heavy.fire()
	else:
		if holdingPrimary:
			primary.fire()
		else:
			secondary.fire()

func move(delta):
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	#check if sprinting, then modify speed if sprinting
	sprinting = Input.is_action_pressed("sprint")
	if sprinting:
		direction = (transform.basis * Vector3(input_dir.x * 0.5, 0, input_dir.y * SPRINT_MULT))
		
	#handle movement and deceleration
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#print("speed: " + str(((position - DEV_pos)/delta).length()))
		#DEV_pos = position
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func pointGun():
	if $CameraController/Camera3D/lookRay.is_colliding():
		var lookpoint = $CameraController/Camera3D/lookRay.get_collision_point()
		$CameraController/GunController.look_at(lookpoint, Vector3(0,1,0))
	else:
		$CameraController/GunController.rotation = Vector3.ZERO

func updateCamera(delta):
	#find mouse movement
	mouseRot.x += tiltInput * delta * 0.7 * verticalsens
	mouseRot.x = clamp(mouseRot.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRot.y += rotInput * delta * 0.6 * horizontalsens
	#move camera up and down
	CameraController.transform.basis = Basis.from_euler(mouseRot)
	CameraController.rotation.y = 0.0
	CameraController.rotation.z = 0.0
	#turn player left and right
	transform.basis = Basis.from_euler(mouseRot)
	rotation.x = 0.0
	rotation.z = 0.0
	#reset input variables
	rotInput = 0.0
	tiltInput = 0.0


func setSens(x,y):
	horizontalsens = x
	verticalsens = y

func swapWeapons():
	if holdingHeavy:
		if holdingPrimary:
			equipPrimary()
		else:
			equipSecondary()
	else:
		if holdingPrimary:
			equipSecondary()
		else:
			equipPrimary()

func swapHeavy():
	equipHeavy()

func equipPrimary():
	holdingPrimary = true
	holdingHeavy = false
	$CameraController/GunController/Weapon2.hide()
	$CameraController/GunController/Weapon3.hide()
	$CameraController/GunController/Weapon1.show()
func equipSecondary():
	holdingPrimary = false
	holdingHeavy = false
	$CameraController/GunController/Weapon1.hide()
	$CameraController/GunController/Weapon3.hide()
	$CameraController/GunController/Weapon2.show()
func equipHeavy():
	holdingHeavy = true
	$CameraController/GunController/Weapon1.hide()
	$CameraController/GunController/Weapon2.hide()
	$CameraController/GunController/Weapon3.show()

func setGuns(allThree):
	match allThree[0]:
		Game.GunType.NONE:
			primary = null
		Game.GunType.RIFLE:
			primary = $CameraController/GunController/Weapon1/Rifle
	match allThree[1]:
		Game.GunType.NONE:
			secondary = null
		Game.GunType.PISTOL:
			secondary = $CameraController/GunController/Weapon2/Pistol
	match allThree[2]:
		Game.GunType.NONE:
			heavy = null
	
	if allThree[0] == Game.GunType.NONE:
		equipSecondary()
	else:
		equipPrimary()

func _on_swap_button_timer_timeout():
	swapHeavy()

func _input(event):
	if event.is_action_pressed("weapon_swap"):
		$SwapButtonTimer.start()
		swapWeapons()
	if event.is_action_released("weapon_swap"):
		$SwapButtonTimer.stop()
	
	if event.is_action_pressed("fire"):
		fireHeldGun()

func _unhandled_input(event):
	mouseInput = !Game.pauseCheck() and event is InputEventMouseMotion
	if mouseInput:
		rotInput = -event.relative.x
		tiltInput = -event.relative.y
