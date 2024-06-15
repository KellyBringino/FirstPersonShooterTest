extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D


const MAX_HEALTH = 2000.0
const RUN_SPEED = 4.0
const WALK_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const REACH_DIST = 0.5
const SHOOT_DIST = 10.0
const SCAN_SPEED = 0.01
const LOOK_SPIN = [180.0,135.0,225.0,90.0,270.0]

enum state {IDLE, PATROLLING, DISCOVERING, CHASING, LOOKING, HIDING, SHOOTING}

var currentState : state = state.IDLE
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
var player

func _ready():
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	$Sprite3D/SubViewport/TextureProgressBar.max_value = MAX_HEALTH
	$Sprite3D/SubViewport/TextureProgressBar.value = health
	player = $"../../Player"

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
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
			elif see.size() == 0 and distanceCheck(player.global_transform.origin):
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
	
	if see.size() > 0:
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

func move(point):
	if global_transform.origin.distance_to(point) <= (REACH_DIST/2.0):
		print("made it")
		return
	nav_agent.set_target_position(point)
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * RUN_SPEED
	elif currentState == state.PATROLLING \
	or currentState == state.IDLE \
	or currentState == state.LOOKING:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * WALK_SPEED

func scanning(delta):
	if scanLeft:
		scanDelta += delta
		$ViewControl.rotation.y = lerp_angle($ViewControl.rotation.y,deg_to_rad(30.0),scanDelta * SCAN_SPEED)
		print(rad_to_deg($ViewControl.rotation.y))
		if $ViewControl.rotation.y >= deg_to_rad(29.0) and $ScanTimer.is_stopped():
			scanDelta = 0.0
			$ScanTimer.start() 
	else:
		scanDelta += delta
		$ViewControl.rotation.y = lerp_angle($ViewControl.rotation.y,deg_to_rad(-30.0),scanDelta * SCAN_SPEED)
		print(rad_to_deg($ViewControl.rotation.y))
		if $ViewControl.rotation.y <= deg_to_rad(-29.0) and $ScanTimer.is_stopped():
			scanDelta = 0.0
			$ScanTimer.start()
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
			$DiscoverTimer.start() 
			print("discovering now")
		state.CHASING:
			currentState = state.CHASING
			suspicious = true
			print("chasing now, lkl is " + str(lastKnowLoc))
		state.LOOKING:
			currentState = state.LOOKING
			$LookingTimer.start()
			suspicious = true
			print("looking now, distance is " + str(global_transform.origin.distance_to(POI)))
		state.SHOOTING:
			currentState = state.SHOOTING
			suspicious = true
			print("shooting now")

func damage(amount):
	health -= amount
	$Sprite3D/SubViewport/TextureProgressBar.value = health
	if health <= 0:
		dead()

func hit(point, damage):
	print(str(health))
	damage(damage)

func dead():
	print("dead")

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
		$MemoryTimer.start()
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
		$LookingTimer.start()


func _on_scan_timer_timeout():
	scanLeft = !scanLeft
