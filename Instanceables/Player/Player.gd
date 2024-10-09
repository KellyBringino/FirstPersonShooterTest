extends CharacterBody3D

const SPEED = 4.0
const SPRINT_MULT = 2.0
const JUMP_VELOCITY = 7
const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)
const INTERACT_PROMPS = [
	"Hold E to refill Health", 
	"Hold E to refill Primary Ammo",
	"Hold E to refill Heavy Ammo",
	"Hold E to Upgrade Damage on ",
	"Hold E to Upgrade Magazine on ",
	"Hold E to Burn Your ",
	"Hold E to Freeze Your "
]

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
var parts : int

var holdingPrimary : bool = true
var holdingHeavy : bool = false
var ADS : bool = false
var leadTrigger : bool = false
var crouching : bool = false
var leftStepNext : bool = false
var jumpGrace : bool = false
var gameover : bool = false
var curMoveState : movestate = movestate.STANDING
var interactNear : Array = []
var heldGun
var primary : Gun
var secondary : Gun
var heavy : Gun

var mouseRot : Vector3
var rotInput : float
var tiltInput : float
var flinchadd : float = 0.0
var horizontalsens : float = 1.0
var verticalsens : float = 1.0

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
@onready var primaryContainer = $CameraController/GunController/Weapon1
@onready var secondaryContainer = $CameraController/GunController/Weapon2
@onready var heavyContainer = $CameraController/GunController/Weapon3
@onready var aimDownSightsRef = $CameraController/AimDownSightsRef
@onready var workbenchSound = $SoundController/WorkbenchSound
@onready var rejectSound = $SoundController/RejectSound

func _ready():
	maxHealth = Game.playerStats.health
	health = maxHealth
	parts = 0
	Game.playerReady()
	get_node("/root/World/GUI").setup()
	$ModelController/doll/Armature/Skeleton3D/LeftArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/LeftLegIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightLegIK.start()

func _physics_process(delta):
	if !gameover:
		handleGrip()
		
		var headrot = Quaternion(Vector3.FORWARD,-$CameraController.rotation.x)
		skl.set_bone_pose_rotation(headBone,headrot)
		
		handleInteractionTooltips()
		handleState()
		
		curMoveState = movestate.STANDING
		if !Game.pauseCheck():
			move(delta)
			holdADS()
			pointGun()
			holdFireHeldGun()
			updateCamera(delta)
		if not is_on_floor():
			curMoveState = movestate.JUMPING
			velocity.y -= gravity * delta
		move_and_slide()

func handleInteractionTooltips():
	if interactNear.size() > 0:
		var closest = closestInteract().getType()
		match closest:
			0:#healthpack
				closestInteract().accessToolTip()
				#if health < maxHealth:
					#var h = ceil((maxHealth - health) * Game.playerStats.healthCost)
					#tooltip(INTERACT_PROMPS[closest]," (" + str(h) + " needed)",parts>=h)
				#else:
					#endtooltip()
			1:#primary ammo
				closestInteract().accessToolTip()
				#if holdingPrimary:
					#if primary.getReserveDiff() > 0:
						#var a = ceil(primary.getReserveDiff() * primary.ammoCost)
						#tooltip(INTERACT_PROMPS[closest]," (" + str(a) + " needed)",parts>=a)
					#else:
						#endtooltip()
				#else:
					#endtooltip()
			2:#heavy ammo
				closestInteract().accessToolTip()
				#if holdingHeavy:
					#if heavy.getReserveDiff() > 0:
						#var a = ceil(heavy.getReserveDiff() * heavy.ammoCost)
						#tooltip(INTERACT_PROMPS[closest]," (" + str(a) + " needed)",parts>=a)
					#else:
						#endtooltip()
			3:#damage bench
				closestInteract().accessToolTip()
				#var a
				#if holdingHeavy:
					#if !heavy.checkDamageLevel():
						#tooltip("Weapon is Max Level","",false)
					#else:
						#a = ceil(heavy.damageUpgradeCost)
						#tooltip(INTERACT_PROMPS[closest] + "Heavy weapon"," (" + str(a) + " needed)",parts>=a)
				#else:
					#if holdingPrimary:
						#if !primary.checkDamageLevel():
							#tooltip("Weapon is Max Level","",false)
						#else:
							#a = ceil(primary.damageUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Primary weapon"," (" + str(a) + " needed)",parts>=a)
					#else:
						#if !secondary.checkDamageLevel():
							#tooltip("Weapon is Max Level","",false)
						#else:
							#a = ceil(secondary.damageUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Secondary weapon"," (" + str(a) + " needed)",parts>=a)
			4:#magazine bench
				closestInteract().accessToolTip()
				#var a
				#if holdingHeavy:
					#if !heavy.checkMagLevel():
						#tooltip("Weapon is Max Level","",false)
					#else:
						#a = ceil(heavy.magUpgradeCost)
						#tooltip(INTERACT_PROMPS[closest] + "Heavy weapon"," (" + str(a) + " needed)",parts>=a)
				#else:
					#if holdingPrimary:
						#if !primary.checkMagLevel():
							#tooltip("Weapon is Max Level","",false)
						#else:
							#a = ceil(primary.magUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Primary weapon"," (" + str(a) + " needed)",parts>=a)
					#else:
						#if !secondary.checkMagLevel():
							#tooltip("Weapon is Max Level","",false)
						#else:
							#a = ceil(secondary.magUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Secondary weapon"," (" + str(a) + " needed)",parts>=a)
			5:#fire bench
				closestInteract().accessToolTip()
				#var a
				#if holdingHeavy:
					#if (heavy.checkElement() != 0):
						#tooltip("Weapon is Already Consumed","",false)
					#else:
						#a = ceil(heavy.elementalUpgradeCost)
						#tooltip(INTERACT_PROMPS[closest] + "Heavy weapon"," (" + str(a) + " needed)",parts>=a)
				#else:
					#if holdingPrimary:
						#if (primary.checkElement() != 0):
							#tooltip("Weapon is Already Consumed","",false)
						#else:
							#a = ceil(primary.elementalUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Primary weapon"," (" + str(a) + " needed)",parts>=a)
					#else:
						#if (secondary.checkElement() != 0):
							#tooltip("Weapon is Already Consumed","",false)
						#else:
							#a = ceil(secondary.elementalUpgradeCost)
							#tooltip(INTERACT_PROMPS[closest] + "Secondary weapon"," (" + str(a) + " needed)",parts>=a)
			6:
				var a
				if holdingHeavy:
					if (heavy.checkElement() != 0):
						tooltip("Weapon is Already Consumed","",false)
					else:
						a = ceil(heavy.elementalUpgradeCost)
						tooltip(INTERACT_PROMPS[closest] + "Heavy weapon"," (" + str(a) + " needed)",parts>=a)
				else:
					if holdingPrimary:
						if (primary.checkElement() != 0):
							tooltip("Weapon is Already Consumed","",false)
						else:
							a = ceil(primary.elementalUpgradeCost)
							tooltip(INTERACT_PROMPS[closest] + "Primary weapon"," (" + str(a) + " needed)",parts>=a)
					else:
						if (secondary.checkElement() != 0):
							tooltip("Weapon is Already Consumed","",false)
						else:
							a = ceil(secondary.elementalUpgradeCost)
							tooltip(INTERACT_PROMPS[closest] + "Secondary weapon"," (" + str(a) + " needed)",parts>=a)
			_:
				endtooltip()
	else:
		endtooltip()

func closestInteract():
	var dist = 10
	var close = null
	for a in interactNear:
		var far = a.global_position.distance_to(global_position)
		if far < dist:
			close = a
	return close

func interact():
	if interactNear.size() > 0:
		closestInteract().activate()

func pay(amount):
	parts -= amount

func weaponStatHelper(w):
	var elem = 0
	if w.fireWeapon:
		elem = 1
	elif w.iceWeapon:
		elem = 2
	get_node("/root/World/GUI").statUpdate(
		w.damageLevel,w.magLevel,elem)

func rejectHelper():
	get_node("/root/World/GUI").rejectToolTip()
	rejectSound.play()

func handleGrip():
	var handle = $ModelController/doll/WeaponTarget.global_transform.origin
	var offhand = $ModelController/doll/OffhandTarget.global_transform.origin
	if holdingHeavy:
		handle = $CameraController/GunController/Weapon3/Gun/Grip\
			.global_transform.origin
		offhand = $CameraController/GunController/Weapon3/Gun/OffhandGrip\
			.global_transform.origin
	else:
		if holdingPrimary:
			handle = $CameraController/GunController/Weapon1/Gun/Grip\
				.global_transform.origin
			offhand = $CameraController/GunController/Weapon1/Gun/OffhandGrip\
				.global_transform.origin
		else:
			handle = $CameraController/GunController/Weapon2/Gun/Grip\
				.global_transform.origin
			offhand = $CameraController/GunController/Weapon2/Gun/OffhandGrip\
				.global_transform.origin
	$ModelController/doll/WeaponTarget.global_transform.origin = handle
	$ModelController/doll/OffhandTarget.global_transform.origin = offhand

func handleState():
	match curMoveState:
		movestate.STANDING:
			if abs($ModelController/doll/LeftLegTarget.global_position\
			.distance_to(leftStand.global_position)) > STAND_STEP_DIS && \
			leftStepNext:
				take_step(leftStand,leftStandRaise,SPRINT_UPSPEED,\
					SPRINT_UPSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position\
			.distance_to(rightStand.global_position)) > STAND_STEP_DIS && \
			!leftStepNext:
				take_step(rightStand,rightStandRaise,SPRINT_UPSPEED,\
					SPRINT_UPSPEED,false)
		movestate.WALKING:
			if abs($ModelController/doll/LeftLegTarget.global_position\
			.distance_to(leftWalk.global_position)) > WALK_STEP_DIS && \
			leftStepNext:
				take_step(leftWalk,leftWalkRaise,WALK_UPSPEED,\
					WALK_DOWNSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position\
			.distance_to(rightWalk.global_position)) > WALK_STEP_DIS && \
			!leftStepNext:
				take_step(rightWalk,rightWalkRaise,WALK_UPSPEED,\
					WALK_DOWNSPEED,false)
		movestate.BACKWARDS:
			if abs($ModelController/doll/LeftLegTarget.global_position\
			.distance_to(leftBack.global_position)) > WALK_STEP_DIS && \
			leftStepNext:
				take_step(leftBack,leftBackRaise,WALK_UPSPEED,\
					WALK_DOWNSPEED,true)
			if abs($ModelController/doll/RightLegTarget.global_position\
			.distance_to(rightBack.global_position)) > WALK_STEP_DIS && \
			!leftStepNext:
				take_step(rightBack,rightBackRaise,WALK_UPSPEED,\
					WALK_DOWNSPEED,false)
		movestate.SPRINTING:
			if abs($ModelController/doll/LeftLegTarget.global_position\
			.distance_to(leftSprint.global_position)) > SPRINT_STEP_DIS && \
			leftStepNext:
				take_step(leftSprint,leftSprintRaise,SPRINT_UPSPEED,\
					SPRINT_UPSPEED, true)
			if abs($ModelController/doll/RightLegTarget.global_position\
			.distance_to(rightSprint.global_position)) > SPRINT_STEP_DIS && \
			!leftStepNext:
				take_step(rightSprint,rightSprintRaise,SPRINT_UPSPEED,\
					SPRINT_UPSPEED,false)
		movestate.STRAFE:
			if abs($ModelController/doll/LeftLegTarget.global_position\
			.distance_to(leftStrafe.global_position)) > STRAFE_STEP_DIS && \
			leftStepNext:
				take_step(leftStrafe,leftStrafeRaise, STRAFE_UPSPEED,\
					STRAFE_DOWNSPEED, true)
			if abs($ModelController/doll/RightLegTarget.global_position\
			.distance_to(rightStrafe.global_position)) > STRAFE_STEP_DIS && \
			!leftStepNext:
				take_step(rightStrafe,rightStrafeRaise, STRAFE_UPSPEED,\
					STRAFE_DOWNSPEED,false)
		movestate.JUMPING:
			$ModelController/doll/LeftLegTarget.global_position = leftJump\
				.global_position
			$ModelController/doll/LeftLegTarget.global_rotation = leftJump\
				.global_rotation
			$ModelController/doll/RightLegTarget.global_position = rightJump\
				.global_position
			$ModelController/doll/RightLegTarget.global_rotation = rightJump\
				.global_rotation

func recoil(amount):
	var t = get_tree().create_tween()
	amount /= 5
	t.tween_property(get_node("."),"flinchadd",flinchadd + amount,0.02)
	t.tween_property(get_node("."),"flinchadd",0.0,0.5)

func take_step(step, stepraise, upspeed, downspeed, left):
	var target_pos = step.global_position
	var half = stepraise.global_position
	
	var t = get_tree().create_tween()
	if left:
		t.tween_property($ModelController/doll/LeftLegTarget,\
			"global_position", half, upspeed)
		t.set_parallel(false)
		t.tween_property($ModelController/doll/LeftLegTarget, \
			"global_position", target_pos, downspeed)
		t.tween_property($ModelController/doll/LeftLegTarget, \
			"global_rotation", step.global_rotation, downspeed)
		t.set_parallel(true)
		t.tween_callback(func(): leftStepNext = false)
	else:
		t.tween_property($ModelController/doll/RightLegTarget,\
			"global_position", half, upspeed)
		t.set_parallel(false)
		t.tween_property($ModelController/doll/RightLegTarget, \
			"global_position", target_pos, downspeed)
		t.tween_property($ModelController/doll/RightLegTarget, \
			"global_rotation", step.global_rotation, downspeed)
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

func holdADS():
	var curgun
	if holdingHeavy:
		curgun = heavy 
	else:
		if holdingPrimary:
			curgun = primary
		else:
			curgun = secondary
	if ADS && !sprinting && !(curgun.scope && curgun.reloading):
		$CameraController/Camera3D.fov = curgun.adsZoom
		
		if curgun.scope:
			get_node("/root/World/GUI").scopein()
			curgun.hide()
		curgun = curgun.get_node("../")
		curgun.global_transform.origin = \
			aimDownSightsRef.global_transform.origin
		curgun.position += Vector3(0.0, curgun.get_child(0).adsOffset,0.0)

func releaseADS():
	var curgun
	if holdingHeavy:
		curgun = heavy 
	else:
		if holdingPrimary:
			curgun = primary
		else:
			curgun = secondary
	$CameraController/Camera3D.fov = 75.0
	
	if curgun.scope:
		get_node("/root/World/GUI").unscope()
		curgun.show()
	curgun = curgun.get_node("../")
	curgun.position = Vector3(0.0,0.0,0.0)

func pointGun():
	var curgun = null
	if holdingHeavy:
		curgun = heavy 
	else:
		if holdingPrimary:
			curgun = primary
		else:
			curgun = secondary
	if $CameraController/Camera3D/lookRay.is_colliding() && !sprinting:
		var lookpoint = $CameraController/Camera3D/lookRay.get_collision_point()
		
		curgun.look_at(lookpoint, Vector3(0,1,0))
	elif sprinting:
		curgun.rotation = Vector3.UP
	else:
		var lookpoint = $CameraController/Camera3D/lookRay/DistanceRef\
			.global_position
		$CameraController/GunController.look_at(lookpoint, Vector3(0,1,0))
		
	curgun.shootRay.force_raycast_update()
	if curgun.shootRay.is_colliding():
		get_node("/root/World/GUI").pointgun\
			(curgun.shootRay.get_collision_point())
	else:
		var faraway = curgun.get_node("BarrelEnd/ShootRay/DistanceRef")\
			.global_position
		get_node("/root/World/GUI").pointgun(faraway) 
		#get_node("/root/World/GUI").dontpointgun()

func tooltip(s,n,a):
	get_node("/root/World/GUI").showTooltip(s,n,a)
func endtooltip():
	get_node("/root/World/GUI").hideTooltip()

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
	sprinting = Input.is_action_pressed("sprint") && \
		Input.is_action_pressed("forward")
	if sprinting:
		releaseADS()
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

func updateCamera(delta):
	#find mouse movement
	if ADS:
		mouseRot.x += (tiltInput * delta * 0.1 * verticalsens) + (flinchadd / 5)
		mouseRot.y += rotInput * delta * 0.075 * horizontalsens
	else:
		mouseRot.x += (tiltInput * delta * 0.5 * verticalsens) + flinchadd
		mouseRot.y += rotInput * delta * 0.4 * horizontalsens
	mouseRot.x = clamp(mouseRot.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
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
		releaseADS()
		$CameraController/GunController/Weapon2.hide()
		$CameraController/GunController/Weapon3.hide()
		$CameraController/GunController/Weapon1.show()
		var elem = 0
		if primary.fireWeapon:
			elem = 1
		elif primary.iceWeapon:
			elem = 2
		Game.equip(holdingHeavy,holdingPrimary,\
			primary.damageLevel,primary.magLevel,elem)
func equipSecondary():
	if secondary != null:
		holdingPrimary = false
		holdingHeavy = false
		heldGun = secondary
		releaseADS()
		$CameraController/GunController/Weapon1.hide()
		$CameraController/GunController/Weapon3.hide()
		$CameraController/GunController/Weapon2.show()
		var elem = 0
		if secondary.fireWeapon:
			elem = 1
		elif secondary.iceWeapon:
			elem = 2
		Game.equip(holdingHeavy,holdingPrimary,\
			secondary.damageLevel,secondary.magLevel,elem)
func equipHeavy():
	if heavy != null:
		releaseADS()
		holdingHeavy = true
		heldGun = heavy
		$CameraController/GunController/Weapon1.hide()
		$CameraController/GunController/Weapon2.hide()
		$CameraController/GunController/Weapon3.show()
		var elem = 0
		if heavy.fireWeapon:
			elem = 1
		elif heavy.iceWeapon:
			elem = 2
		Game.equip(holdingHeavy,holdingPrimary,\
			heavy.damageLevel,heavy.magLevel,elem)

func addParts(amount):
	parts += amount
	Game.score += amount

func setSens(x,y):
	horizontalsens = x
	verticalsens = y

func setHealth(amount):
	maxHealth = amount
	health = amount
func getHealth():
	return health

func heal():
	health = maxHealth
	get_node("/root/World/GUI").setHealth(health)

func hit(d,_point):
	health -= d
	get_node("/root/World/GUI").setHealth(health)
	if health <= 0:
		gameover = true
		Game.GameOver()

func setGuns(allThree):
	match allThree[0]:
		Game.GunType.NONE:
			primary = null
		Game.GunType.RIFLE:
			primary = $CameraController/GunController/Weapon1/Gun
		Game.GunType.SNIPER:
			primary = $CameraController/GunController/Weapon1/Gun
		Game.GunType.SHOTGUN:
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
		
		if event.is_action_pressed("interact"):
			interact()
		
		if event.is_action_pressed("fire"):
			singleFireHeldGun()
			leadTrigger = true
		elif event.is_action_released("fire"):
			leadTrigger = false
		
		if event.is_action_pressed("ads"):
			ADS = true
		elif event.is_action_released("ads"):
			ADS = false
			releaseADS()
		
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

func _on_interactable_detection_area_entered(area):
	interactNear.append(area)
func _on_interactable_detection_area_exited(area):
	for index in interactNear.size():
		if interactNear[index] == area:
			interactNear.remove_at(index)
			break
