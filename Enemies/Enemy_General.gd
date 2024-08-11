class_name Enemy_General
extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var skl : Skeleton3D = $ModelController/doll/Armature/Skeleton3D
@onready var headBone = skl.find_bone("head")
@onready var leftSprint = $StepTargetController/LeftSprintRayCast/LeftStepTarget
@onready var leftSprintRaise = $StepTargetController/LeftSprintRayCast/LeftRaiseTarget
@onready var rightSprint = $StepTargetController/RightSprintRayCast/RightStepTarget
@onready var rightSprintRaise = $StepTargetController/RightSprintRayCast/RightRaiseTarget
@onready var leftStand = $StepTargetController/LeftStandRayCast/LeftStepTarget
@onready var leftStandRaise = $StepTargetController/LeftStandRayCast/LeftRaiseTarget
@onready var rightStand = $StepTargetController/RightStandRayCast/RightStepTarget
@onready var rightStandRaise = $StepTargetController/RightStandRayCast/RightRaiseTarget
@onready var lookTimer = $TimerController/LookCheck
@onready var pathTimer = $TimerController/PathfindTimer

const RUN_SPEED = 4.0
const JUMP_VELOCITY = 4.5
const REACH_DIST = 0.5
const SHOOT_DIST = 10.0
const SPRINT_STEP_DIS = 1.2
const STEP_UP_SPEED = 0.1
const STEP_SPEED = 0.03
const WALK_STEP_DIS = 0.7
const STAND_STEP_DIS = 0.1

enum state {CHASING, HIDING, SHOOTING}

var currentState : state = state.CHASING
var maxHealth = 2000.0
var health : float = 2000.0
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var lastKnowLoc : Vector3
var vision : Array = []
var see : Array = []
var suspicious : bool = false
var leftStepNext : bool = false
var player

func _ready():
	maxHealth = Game.enemyHealth
	health = maxHealth
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	$Sprite3D/SubViewport/TextureProgressBar.max_value = maxHealth
	$Sprite3D/SubViewport/TextureProgressBar.value = health
	player = $"../../Player"
	$ModelController/doll/Armature/Skeleton3D/LeftArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightArmIK.start()
	$ModelController/doll/Armature/Skeleton3D/LeftLegIK.start()
	$ModelController/doll/Armature/Skeleton3D/RightLegIK.start()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	$ModelController/doll/WeaponTarget.global_transform.origin \
	= $ViewControl/vision/GunController/Weapon/Gun/Grip.global_transform.origin
	
	if(see.size() > 0):
		$ViewControl.look_at(lastKnowLoc)
		$ViewControl/vision/GunController/Weapon.look_at(lastKnowLoc)
	
	var headrot = Quaternion(Vector3.UP,$ViewControl.rotation.y)
	skl.set_bone_pose_rotation(headBone,headrot)
	
	if currentState == state.CHASING:
		if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftSprint.global_position)) > SPRINT_STEP_DIS && leftStepNext:
			stepL(leftSprint,leftSprintRaise)
		if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightSprint.global_position)) > SPRINT_STEP_DIS && !leftStepNext:
			stepR(rightSprint,rightSprintRaise)
	elif currentState == state.SHOOTING:
		if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(leftStand.global_position)) > STAND_STEP_DIS && leftStepNext:
			stepL(leftStand,leftStandRaise)
		if abs($ModelController/doll/RightLegTarget.global_position.distance_to(rightStand.global_position)) > STAND_STEP_DIS && !leftStepNext:
			stepR(rightStand,rightStandRaise)
	
	handleStates(delta)
	
	if see.size() > 0:
		look_at(lastKnowLoc,Vector3.UP)
		rotation.x = 0.0
		rotation.z = 0.0
	else:
		var vel = velocity.normalized()
		vel = global_transform.origin + vel
		look_at(lastKnowLoc,Vector3.UP)
		rotation.x = 0.0
		rotation.z = 0.0
	
	velocity.x = 0
	velocity.z = 0
	if currentState == state.CHASING:
		move()
	move_and_slide()

func handleStates(delta):
	match currentState:
		state.CHASING:
			if see.size() > 0 and distanceCheck(lastKnowLoc):
				stateChange(state.SHOOTING)
			elif see.size() == 0 \
			and distanceCheck(player.global_transform.origin):
				look_at(player.position,Vector3.UP)
				rotation.x = 0.0
				rotation.z = 0.0
			elif reached(lastKnowLoc):
				stateChange(state.SHOOTING)
			else:
				lastKnowLoc = player.global_transform.origin
		state.SHOOTING:
			if !distanceCheck(lastKnowLoc):
				stateChange(state.CHASING)
			elif see.size() == 0:
				stateChange(state.CHASING)

func stepL(step, stepraise):
	var ltarget_pos = step.global_position
	var lhalf = stepraise.global_position
	
	var t = get_tree().create_tween()
	t.tween_property($ModelController/doll/LeftLegTarget,"global_position", lhalf, STEP_UP_SPEED)
	t.set_parallel(false)
	t.tween_property($ModelController/doll/LeftLegTarget, "global_position", ltarget_pos, STEP_SPEED)
	t.tween_property($ModelController/doll/LeftLegTarget, "global_rotation", step.global_rotation, STEP_SPEED)
	t.set_parallel(true)
	t.tween_callback(func(): leftStepNext = false)
func stepR(step,stepraise):
	var rtarget_pos = step.global_position
	var rhalf = stepraise.global_position
	
	var t = get_tree().create_tween()
	t.set_parallel(false)
	t.tween_property($ModelController/doll/RightLegTarget,"global_position", rhalf, STEP_UP_SPEED)
	t.set_parallel(false)
	t.tween_property($ModelController/doll/RightLegTarget, "global_position", rtarget_pos, STEP_SPEED)
	t.tween_property($ModelController/doll/RightLegTarget, "global_rotation", step.global_rotation, STEP_SPEED)
	t.set_parallel(true)
	t.tween_callback(func(): leftStepNext = true)

func alert(point):
	if currentState == state.CHASING:
		lastKnowLoc = point
		stateChange(state.CHASING)

func move():
	if global_transform.origin.distance_to(lastKnowLoc) <= (REACH_DIST/2.0):
		print("made it")
		return
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING:
		velocity = ((nextNavPoint - global_transform.origin) \
		* Vector3(1,0,1)).normalized() * RUN_SPEED

func reached(point):
	var e = Vector2(global_transform.origin.x,global_transform.origin.z)
	var p = Vector2(point.x,point.z)
	var v = e.distance_to(p) <= REACH_DIST
	if v:
		print("made it")
	return v
func distanceCheck(point):
	return global_transform.origin.distance_to(point) <= SHOOT_DIST

func stateChange(nState):
	match nState:
		state.CHASING:
			currentState = state.CHASING
			suspicious = true
			print("chasing now, lkl is " + str(lastKnowLoc))
		state.SHOOTING:
			currentState = state.SHOOTING
			suspicious = true
			print("shooting now")

func damage(point, amount, source):
	health -= amount
	$Sprite3D/SubViewport/TextureProgressBar.value = health
	if health <= 0:
		dead(point,source)
func hit(point, d, source):
	damage(point,d,source)
func dead(_point, source):
	match source:
		0:#hitscan
			queue_free()
		1:#explosion
			queue_free()

func _on_vision_body_entered(body):
	if body.collision_layer == 8:
		vision.append(body)

func _on_vision_body_exited(body):
	for index in vision.size():
		if vision[index] == body:
			vision.remove_at(index)
			break

func _on_look_check_timeout():
	see = []
	for v in vision:
		$LookRay.look_at(v.global_transform.origin, Vector3.UP)
		$LookRay.force_raycast_update()
		if $LookRay.is_colliding():
			var collider = $LookRay.get_collider()
			if collider == v:
				see.append(v)
	
	if see.size() > 0:
		lastKnowLoc = Vector3.ZERO
		for o in see:
			lastKnowLoc += o.global_transform.origin
		lastKnowLoc /= see.size()

func _on_pathfind_timer_timeout():
	nav_agent.set_target_position(lastKnowLoc)
