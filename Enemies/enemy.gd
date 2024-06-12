extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D


const MAX_HEALTH = 2000.0
const RUN_SPEED = 1.0
const WALK_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const REACH_DIST = 0.5
const SHOOT_DIST = 10.0
const LOOK_SPIN = [180.0,135.0,225]

enum state {IDLE, PATROLLING, DISCOVERING, CHASING, LOOKING, HIDING, SHOOTING}

var health = 2000.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var POI : Vector3
var player
var currentState : state = state.IDLE
var vision : Array = []
var see : Array = []
var lastKnowLoc : Vector3
var memory : bool = false

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
			pass
		state.PATROLLING:
			if reached(POI):
				currentState = state.IDLE
		state.DISCOVERING:
			pass
		state.CHASING:
			if see.size() > 0 and distanceCheck(lastKnowLoc):
				shoot()
			elif see.size() == 0 and distanceCheck(lastKnowLoc):
				look_at(player.position,Vector3.UP)
				rotation.x = 0.0
				rotation.z = 0.0
			elif reached(lastKnowLoc):
				look()
			else:
				POI = lastKnowLoc
		state.LOOKING:
			if !memory:
				idle()
		state.SHOOTING:
			if !distanceCheck(lastKnowLoc):
				chase()
			if see.size() == 0:
				chase()
	
	if see.size() > 0:
		look_at(lastKnowLoc,Vector3.UP)
		rotation.x = 0.0
		rotation.z = 0.0
	
	move(POI)
	move_and_slide()

func move(point):
	velocity.x = 0
	velocity.z = 0
	if reached(point):
		return
	nav_agent.set_target_position(point)
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * RUN_SPEED
	elif currentState == state.PATROLLING \
	or currentState == state.IDLE \
	or currentState == state.LOOKING:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * WALK_SPEED

func reached(point):
	return (global_transform.origin.x > point.x - REACH_DIST \
	and global_transform.origin.x < point.x + REACH_DIST )\
	or (global_transform.origin.y > point.y - REACH_DIST \
	and global_transform.origin.y < point.y + REACH_DIST)
func distanceCheck(point):
	return global_transform.origin.distance_to(point) < SHOOT_DIST

func idle():
	currentState = state.IDLE
	print("idle now")
func patrol():
	currentState = state.PATROLLING
	print("patrolling now")
func discover():
	currentState = state.DISCOVERING
	print("discovering now")
	$DiscoverTimer.start() 
func look():
	currentState = state.LOOKING
	print("looking now, distance is " + str(global_transform.origin.distance_to(POI)))
func chase():
	currentState = state.CHASING
	print("chasing now, lkl is " + str(lastKnowLoc))
func shoot():
	currentState = state.SHOOTING
	print("shooting now")

func damage(amount):
	health -= amount
	$Sprite3D/SubViewport/TextureProgressBar.value = health

func hit(point, damage):
	print(str(health))
	damage(damage)

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
			discover()
		lastKnowLoc = Vector3.ZERO
		for o in see:
			lastKnowLoc += o.global_transform.origin
		lastKnowLoc /= see.size()

func _on_patrol_timer_timeout():
	if currentState == state.IDLE:
		patrol()

func _on_discover_timer_timeout():
	if currentState == state.DISCOVERING:
		if see.size() > 0:
			if distanceCheck(lastKnowLoc):
				shoot()
			else:
				chase()
		else:
			chase()

func _on_memory_timer_timeout():
	memory = false
	if currentState == state.LOOKING:
		idle()


func _on_looking_timer_timeout():
	if currentState == state.LOOKING:
		var r = randi()%3
		transform.basis = transform.basis.rotated(Vector3.UP, deg_to_rad(LOOK_SPIN[r]))
		$LookingTimer.start()
