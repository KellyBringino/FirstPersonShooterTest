extends CharacterBody3D

const SPEED = 4.0
const SPRINT_MULT = 2.0
const JUMP_VELOCITY = 7
const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)

const SPRINT_STEP_DIS = 1.2
const WALK_STEP_DIS = 0.7
const STAND_STEP_DIS = 0.1
const STRAFE_STEP_DIS = 0.01

const SPRINT_UPSPEED = 0.1
const SPRINT_DOWNSPEED = 0.1
const WALK_UPSPEED = 0.1
const WALK_DOWNSPEED = 0.1
const STRAFE_UPSPEED = .05
const STRAFE_DOWNSPEED = .05

enum movestate {SPRINTING, WALKING, STANDING, JUMPING, BACKWARDS, STRAFE}

var sprinting : bool = false
var health : float
var maxHealth : float

var holdingPrimary : bool = true
var holdingHeavy : bool = false
var leadTrigger : bool = false
var crouching : bool = false
var leftStepNext : bool = false
var jumpGrace : bool = false
var curMoveState : movestate = movestate.STANDING
var heldGun
var primary
var secondary
var heavy

var mouseRot : Vector3
var rotInput : float
var tiltInput : float
var horizontalsens : float = 1.0
var verticalsens : float = 1.0

#var DEV_pos : Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var CameraController = get_node("CameraController")
@onready var skl : Skeleton3D = $ModelController/doll/Armature/Skeleton3D
@onready var headBone = skl.find_bone("head")
@onready var leftSprint = $StepTargetController/LeftSprintRayCast/LeftStepTarget
@onready var leftSprintRaise = $StepTargetController/LeftSprintRayCast/LeftRaiseTarget
@onready var rightSprint = $StepTargetController/RightSprintRayCast/RightStepTarget
@onready var rightSprintRaise = $StepTargetController/RightSprintRayCast/RightRaiseTarget
@onready var leftWalk = $StepTargetController/LeftWalkRayCast/LeftStepTarget
@onready var leftWalkRaise = $StepTargetController/LeftWalkRayCast/LeftRaiseTarget
@onready var rightWalk = $StepTargetController/RightWalkRayCast/RightStepTarget
@onready var rightWalkRaise = $StepTargetController/RightWalkRayCast/RightRaiseTarget
@onready var leftBack = $StepTargetController/LeftBackRayCast/LeftStepTarget
@onready var leftBackRaise = $StepTargetController/LeftBackRayCast/LeftRaiseTarget
@onready var rightBack = $StepTargetController/RightBackRayCast/RightStepTarget
@onready var rightBackRaise = $StepTargetController/RightBackRayCast/RightRaiseTarget
@onready var leftStand = $StepTargetController/LeftStandRayCast/LeftStepTarget
@onready var leftStandRaise = $StepTargetController/LeftStandRayCast/LeftRaiseTarget
@onready var rightStand = $StepTargetController/RightStandRayCast/RightStepTarget
@onready var rightStandRaise = $StepTargetController/RightStandRayCast/RightRaiseTarget
@onready var leftStrafe = $StepTargetController/LeftStrafeRayCast/LeftStepTarget
@onready var leftStrafeRaise = $StepTargetController/LeftStrafeRayCast/LeftRaiseTarget
@onready var rightStrafe = $StepTargetController/RightStrafeRayCast/RightStepTarget
@onready var rightStrafeRaise = $StepTargetController/RightStrafeRayCast/RightRaiseTarget
@onready var rightJump = $StepTargetController/RightJumpTarget
@onready var leftJump = $StepTargetController/LeftJumpTarget

func _ready():
	maxHealth = Game.playerHealth
	health = maxHealth
	Game.playerReady()
	$ModelController/doll/Armature/Skeleton3D/LeftArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/LeftLegIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightLegIK.start()

func _physics_process(delta):
	var handle = $ModelController/doll/WeaponTarget.global_transform.origin
	var offhand = $ModelController/doll/OffhandTarget.global_transform.origin
	if holdingHeavy:
		handle = $CameraController/GunController/Weapon3/Gun/Grip.global_transform.origin
		offhand = $CameraController/GunController/Weapon3/Gun/OffhandGrip.global_transform.origin
	else:
		if holdingPrimary:
			handle = $CameraController/GunController/Weapon1/Gun/Grip.global_transform.origin
			offhand = $CameraController/GunController/Weapon1/Gun/OffhandGrip.global_transform.origin
		else:
			handle = $CameraController/GunController/Weapon2/Gun/Grip.global_transform.origin
			offhand = $CameraController/GunController/Weapon2/Gun/OffhandGrip.global_transform.origin
	$ModelController/doll/WeaponTarget.global_transform.origin = handle
	$ModelController/doll/OffhandTarget.global_transform.origin = offhand
	
	var headrot = Quaternion(Vector3.FORWARD,-$CameraController.rotation.x)
	skl.set_bone_pose_rotation(headBone,headrot)
	
	match curMoveState:
		movestate.STANDING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftStand.global_position)) > STAND_STEP_DIS && leftStepNext:
				take_step(leftStand,leftStandRaise,SPRINT_UPSPEED,SPRINT_UPSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightStand.global_position)) > STAND_STEP_DIS && !leftStepNext:
				take_step(rightStand,rightStandRaise,SPRINT_UPSPEED,SPRINT_UPSPEED,false)
		movestate.WALKING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftWalk.global_position)) > WALK_STEP_DIS && leftStepNext:
				take_step(leftWalk,leftWalkRaise,WALK_UPSPEED,WALK_DOWNSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightWalk.global_position)) > WALK_STEP_DIS && !leftStepNext:
				take_step(rightWalk,rightWalkRaise,WALK_UPSPEED,WALK_DOWNSPEED,false)
		movestate.BACKWARDS:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftBack.global_position)) > WALK_STEP_DIS && leftStepNext:
				take_step(leftBack,leftBackRaise,WALK_UPSPEED,WALK_DOWNSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightBack.global_position)) > WALK_STEP_DIS && !leftStepNext:
				take_step(rightBack,rightBackRaise,WALK_UPSPEED,WALK_DOWNSPEED,false)
		movestate.SPRINTING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftSprint.global_position)) > SPRINT_STEP_DIS && leftStepNext:
				take_step(leftSprint,leftSprintRaise,SPRINT_UPSPEED,SPRINT_UPSPEED, true)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightSprint.global_position)) > SPRINT_STEP_DIS && !leftStepNext:
				take_step(rightSprint,rightSprintRaise,SPRINT_UPSPEED,SPRINT_UPSPEED,false)
		movestate.STRAFE:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftStrafe.global_position)) > STRAFE_STEP_DIS && leftStepNext:
				take_step(leftStrafe,leftStrafeRaise, STRAFE_UPSPEED, STRAFE_DOWNSPEED, true)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightStrafe.global_position)) > STRAFE_STEP_DIS && !leftStepNext:
				take_step(rightStrafe,rightStrafeRaise, STRAFE_UPSPEED, STRAFE_DOWNSPEED,false)
		movestate.JUMPING:
			$ModelController/doll/LeftLegTarget.global_position = leftJump.global_position
			$ModelController/doll/LeftLegTarget.global_rotation = leftJump.global_rotation
			$ModelController/doll/RightLegTarget.global_position = rightJump.global_position
			$ModelController/doll/RightLegTarget.global_rotation = rightJump.global_rotation
	
	pointGun()
	
	curMoveState = movestate.STANDING
	if !Game.pauseCheck():
		holdFireHeldGun()
		move(delta)
		updateCamera(delta)
	
	if not is_on_floor():
		curMoveState = movestate.JUMPING
		velocity.y -= gravity * delta
	
	move_and_slide()

func take_step(step, stepraise, upspeed, downspeed, left):
	var target_pos = step.global_position
	var half = stepraise.global_position
	
	var t = get_tree().create_tween()
	if left:
		t.tween_property($ModelController/doll/LeftLegTarget,"global_position", half, upspeed)
		t.set_parallel(false)
		t.tween_property($ModelController/doll/LeftLegTarget, "global_position", target_pos, downspeed)
		t.tween_property($ModelController/doll/LeftLegTarget, "global_rotation", step.global_rotation, downspeed)
		t.set_parallel(true)
		t.tween_callback(func(): leftStepNext = false)
	else:
		t.tween_property($ModelController/doll/RightLegTarget,"global_position", half, upspeed)
		t.set_parallel(false)
		t.tween_property($ModelController/doll/RightLegTarget, "global_position", target_pos, downspeed)
		t.tween_property($ModelController/doll/RightLegTarget, "global_rotation", step.global_rotation, downspeed)
		t.set_parallel(true)
		t.tween_callback(func(): leftStepNext = true)

func holdFireHeldGun():
	if leadTrigger && !sprinting:
		heldGun.heldFire()

func singleFireHeldGun():
	if !sprinting:
		heldGun.singleFire()

func releaseFireHeldGun():
	if !sprinting:
		heldGun.releaseFire()

func reloadHeldGun():
	heldGun.reload()

func move(_delta):
	# Get the input direction
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	var sprintDir = (transform.basis * Vector3(0 , 0, -SPRINT_MULT))
	
	#change state according to movement
	if input_dir.x < 0:
		curMoveState = movestate.STRAFE
	if input_dir.x > 0:
		curMoveState = movestate.STRAFE
	if input_dir.y > 0:
		curMoveState = movestate.BACKWARDS
	if input_dir.y < 0:
		curMoveState = movestate.WALKING
	
	#check if sprinting, then modify speed if sprinting
	sprinting = Input.is_action_pressed("sprint") && Input.is_action_pressed("forward")
	if sprinting:
		$CameraController/Camera3D/AnimationPlayer.play("SHeadBob")
		curMoveState = movestate.SPRINTING
		velocity.x = sprintDir.x * SPEED
		velocity.z = sprintDir.z * SPEED
	#handle movement and deceleration
	elif direction:
		$CameraController/Camera3D/AnimationPlayer.play("HeadBob")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_action_just_pressed("jump"):
		jumpGrace = true
		$JumpGraceTimer.start()
		
	# Handle jump.
	if jumpGrace and is_on_floor():
		jump()

func jump():
	curMoveState = movestate.JUMPING
	velocity.y = JUMP_VELOCITY

func pointGun():
	if $CameraController/Camera3D/lookRay.is_colliding() && !sprinting:
		var lookpoint = $CameraController/Camera3D/lookRay.get_collision_point()
		$CameraController/GunController.look_at(lookpoint, Vector3(0,1,0))
	elif sprinting:
		$CameraController/GunController.rotation = Vector3.UP
	else:
		$CameraController/GunController.rotation = Vector3.ZERO

func updateCamera(delta):
	#find mouse movement
	mouseRot.x += tiltInput * delta * 0.5 * verticalsens
	mouseRot.x = clamp(mouseRot.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRot.y += rotInput * delta * 0.4 * horizontalsens
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

func equipPrimary():
	if primary != null:
		holdingPrimary = true
		holdingHeavy = false
		heldGun = primary
		$CameraController/GunController/Weapon2.hide()
		$CameraController/GunController/Weapon3.hide()
		$CameraController/GunController/Weapon1.show()
		Game.equip(holdingHeavy,holdingPrimary)
func equipSecondary():
	if secondary != null:
		holdingPrimary = false
		holdingHeavy = false
		heldGun = secondary
		$CameraController/GunController/Weapon1.hide()
		$CameraController/GunController/Weapon3.hide()
		$CameraController/GunController/Weapon2.show()
		Game.equip(holdingHeavy,holdingPrimary)
func equipHeavy():
	if heavy != null:
		holdingHeavy = true
		heldGun = heavy
		$CameraController/GunController/Weapon1.hide()
		$CameraController/GunController/Weapon2.hide()
		$CameraController/GunController/Weapon3.show()
		Game.equip(holdingHeavy,holdingPrimary)

func setSens(x,y):
	horizontalsens = x
	verticalsens = y

func setHealth(amount):
	maxHealth = amount
	health = amount
func getHealth():
	return health

func setGuns(allThree):
	match allThree[0]:
		Game.GunType.NONE:
			primary = null
		Game.GunType.RIFLE:
			primary = $CameraController/GunController/Weapon1/Gun
		Game.GunType.SNIPER:
			primary = $CameraController/GunController/Weapon1/Gun
	match allThree[1]:
		Game.GunType.NONE:
			secondary = null
		Game.GunType.PISTOL:
			secondary = $CameraController/GunController/Weapon2/Gun
		Game.GunType.REVOLVER:
			secondary = $CameraController/GunController/Weapon2/Gun
	match allThree[2]:
		Game.GunType.NONE:
			heavy = null
		Game.GunType.ROCKETLAUNCHER:
			heavy = $CameraController/GunController/Weapon3/Gun
	
	if allThree[0] == Game.GunType.NONE:
		equipSecondary()
	else:
		equipPrimary()

func _on_swap_button_timer_timeout():
	equipHeavy()

func _input(event):
	if !Game.pauseCheck():
		if event.is_action_pressed("weapon_swap"):
			$SwapButtonTimer.start()
			swapWeapons()
		if event.is_action_released("weapon_swap"):
			$SwapButtonTimer.stop()
		
		if event.is_action_pressed("fire"):
			singleFireHeldGun()
			leadTrigger = true
		elif event.is_action_released("fire"):
			leadTrigger = false
			
		if event.is_action_pressed("reload"):
			reloadHeldGun()
			
		if event.is_action_pressed("crouch"):
			crouching = true
		elif event.is_action_released("crouch"):
			crouching = false

func _unhandled_input(event):
	if !Game.pauseCheck() and event is InputEventMouseMotion:
		rotInput = -event.relative.x
		tiltInput = -event.relative.y


func _on_jump_grace_timer_timeout():
	jumpGrace = false
