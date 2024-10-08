extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
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
@onready var leftStand = $StepTargetController/LeftStandRayCast/LeftStepTarget
@onready var leftStandRaise = $StepTargetController/LeftStandRayCast/LeftRaiseTarget
@onready var rightStand = $StepTargetController/RightStandRayCast/RightStepTarget
@onready var rightStandRaise = $StepTargetController/RightStandRayCast/RightRaiseTarget
@onready var lookTimer = $TimerController/LookCheck
@onready var patTimer = $TimerController/PatrolTimer
@onready var DisTimer = $TimerController/DiscoverTimer
@onready var memTimer = $TimerController/MemoryTimer
@onready var lookingTimer = $TimerController/LookingTimer
@onready var scanTimer = $TimerController/ScanTimer

const RUN_SPEED = 4.0
const WALK_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const REACH_DIST = 0.5
const SHOOT_DIST = 10.0
const SCAN_SPEED = 0.01
const SPRINT_STEP_DIS = 1.2
const STEP_UP_SPEED = 0.1
const STEP_SPEED = 0.03
const WALK_STEP_DIS = 0.7
const STAND_STEP_DIS = 0.1
const LOOK_SPIN = [180.0,135.0,225.0,90.0,270.0]
const WALK_STATES : Array = [state.PATROLLING, state.IDLE, state.LOOKING]

enum state {IDLE, PATROLLING, DISCOVERING, CHASING, LOOKING, HIDING, SHOOTING}

var currentState : state = state.IDLE
var maxHealth = 2000.0
var health : float = 2000.0
var scanDelta : float = 0.0
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var POI : Vector3
var lastKnowLoc : Vector3
var vision : Array = []
var see : Array = []
var memory : bool = false
var scanLeft : bool = false
var suspicious : bool = false
var leftStepNext : bool = false
var player

func _ready():
	maxHealth = Game.enemyStats.health
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
	
	match currentState:
		state.IDLE, state.DISCOVERING, state.LOOKING, state.SHOOTING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(\
			leftStand.global_position)) > STAND_STEP_DIS && leftStepNext:
				stepL(leftStand,leftStandRaise)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(\
			rightStand.global_position)) > STAND_STEP_DIS && !leftStepNext:
				stepR(rightStand,rightStandRaise)
		state.PATROLLING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(\
			leftWalk.global_position)) > WALK_STEP_DIS && leftStepNext:
				stepL(leftWalk,leftWalkRaise)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(\
			rightWalk.global_position)) > WALK_STEP_DIS && !leftStepNext:
				stepR(rightWalk,rightWalkRaise)
		state.CHASING:
			if abs($ModelController/doll/LeftLegTarget.global_position.distance_to(\
			leftSprint.global_position)) > SPRINT_STEP_DIS && leftStepNext:
				stepL(leftSprint,leftSprintRaise)
			if abs($ModelController/doll/RightLegTarget.global_position.distance_to(\
			rightSprint.global_position)) > SPRINT_STEP_DIS && !leftStepNext:
				stepR(rightSprint,rightSprintRaise)
	
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
	if currentState != state.IDLE \
	and currentState != state.DISCOVERING \
	and currentState != state.LOOKING \
	and currentState != state.SHOOTING:
		move(POI)
	move_and_slide()

func handleStates(delta):
	match currentState:
		state.IDLE:
			scanning(delta)
		state.PATROLLING:
			if reached(POI):
				currentState = state.IDLE
			else:
				scanning(delta)
		state.DISCOVERING:
			stopScanning()
		state.CHASING:
			if see.size() > 0 and distanceCheck(lastKnowLoc):
				stateChange(state.SHOOTING)
			elif see.size() == 0 \
			and distanceCheck(player.global_transform.origin):
				look_at(player.position,Vector3.UP)
				rotation.x = 0.0
				rotation.z = 0.0
			elif reached(lastKnowLoc):
				stateChange(state.LOOKING)
			else:
				stopScanning()
				POI = lastKnowLoc
		state.LOOKING:
			if !memory:
				stateChange(state.IDLE)
			else:
				scanning(delta)
		state.SHOOTING:
			if !distanceCheck(lastKnowLoc):
				stateChange(state.CHASING)
			elif see.size() == 0:
				stateChange(state.CHASING)
			else:
				stopScanning()

func stepL(step, stepraise):
	var ltarget_pos = step.global_position
	var lhalf = stepraise.global_position
	
	var t = get_tree().create_tween()
	t.tween_property($ModelController/doll/LeftLegTarget,"global_position"\
		, lhalf, STEP_UP_SPEED)
	t.set_parallel(false)
	t.tween_property($ModelController/doll/LeftLegTarget, "global_position"\
		, ltarget_pos, STEP_SPEED)
	t.tween_property($ModelController/doll/LeftLegTarget, "global_rotation"\
		, step.global_rotation, STEP_SPEED)
	t.set_parallel(true)
	t.tween_callback(func(): leftStepNext = false)
func stepR(step,stepraise):
	var rtarget_pos = step.global_position
	var rhalf = stepraise.global_position
	
	var t = get_tree().create_tween()
	t.set_parallel(false)
	t.tween_property($ModelController/doll/RightLegTarget,"global_position"\
		, rhalf, STEP_UP_SPEED)
	t.set_parallel(false)
	t.tween_property($ModelController/doll/RightLegTarget, "global_position"\
		, rtarget_pos, STEP_SPEED)
	t.tween_property($ModelController/doll/RightLegTarget, "global_rotation"\
		, step.global_rotation, STEP_SPEED)
	t.set_parallel(true)
	t.tween_callback(func(): leftStepNext = true)

func alert(point):
	var statelist = [state.IDLE,state.PATROLLING,state.LOOKING,state.CHASING]
	if statelist.has(currentState):
		lastKnowLoc = point
		memTimer.start()
		stateChange(state.CHASING)

func move(point):
	if global_transform.origin.distance_to(point) <= (REACH_DIST/2.0):
		print("made it")
		return
	nav_agent.set_target_position(point)
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING:
		velocity = ((nextNavPoint - global_transform.origin) \
		* Vector3(1,0,1)).normalized() * RUN_SPEED
	elif WALK_STATES.has(currentState):
		velocity = ((nextNavPoint - global_transform.origin) \
		* Vector3(1,0,1)).normalized() * WALK_SPEED

func scanning(delta):
	if scanLeft:
		scanDelta += delta
		$ViewControl.rotation.y = lerp_angle($ViewControl.rotation.y,\
			deg_to_rad(30.0),scanDelta * SCAN_SPEED)
		if $ViewControl.rotation.y >= deg_to_rad(29.0) and scanTimer.is_stopped():
			scanDelta = 0.0
			scanTimer.start() 
	else:
		scanDelta += delta
		$ViewControl.rotation.y = lerp_angle($ViewControl.rotation.y,\
			deg_to_rad(-30.0),scanDelta * SCAN_SPEED)
		if $ViewControl.rotation.y <= deg_to_rad(-29.0) and scanTimer.is_stopped():
			scanDelta = 0.0
			scanTimer.start()
func stopScanning():
	scanDelta = 0.0
	$ViewControl.rotation.y = 0.0

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
		state.IDLE:
			currentState = state.IDLE
			suspicious = false
			print("idle now")
		state.PATROLLING:
			currentState = state.PATROLLING
			suspicious = false
			print("patrolling now")
		state.DISCOVERING:
			currentState = state.DISCOVERING
			suspicious = true
			DisTimer.start() 
			print("discovering now")
		state.CHASING:
			currentState = state.CHASING
			suspicious = true
			print("chasing now, lkl is " + str(lastKnowLoc))
		state.LOOKING:
			currentState = state.LOOKING
			lookingTimer.start()
			suspicious = true
			print("looking now, distance is " + str(global_transform.origin.distance_to(POI)))
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
		memory = true
		memTimer.start()
		if currentState == state.IDLE \
		or currentState == state.PATROLLING \
		or currentState == state.LOOKING:
			stateChange(state.DISCOVERING)
		lastKnowLoc = Vector3.ZERO
		for o in see:
			lastKnowLoc += o.global_transform.origin
		lastKnowLoc /= see.size()

func _on_patrol_timer_timeout():
	if currentState == state.IDLE:
		stateChange(state.PATROLLING)

func _on_discover_timer_timeout():
	if currentState == state.DISCOVERING:
		if see.size() > 0:
			if distanceCheck(lastKnowLoc):
				stateChange(state.SHOOTING)
			else:
				stateChange(state.CHASING)
		else:
			stateChange(state.CHASING)

func _on_memory_timer_timeout():
	memory = false
	if currentState == state.LOOKING:
		stateChange(state.IDLE)

func _on_looking_timer_timeout():
	if currentState == state.LOOKING:
		var r = randi()%3
		transform.basis = transform.basis.rotated(Vector3.UP, deg_to_rad(LOOK_SPIN[r]))
		lookingTimer.start()


func _on_scan_timer_timeout():
	scanLeft = !scanLeft
