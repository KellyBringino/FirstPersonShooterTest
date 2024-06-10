extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D


const MAX_HEALTH = 2000.0
const RUN_SPEED = 4.0
const WALK_SPEED = 2.0
const JUMP_VELOCITY = 4.5

enum state {IDLE, PATROLLING, CHASING, LOOKING, HIDING, SHOOTING}

var health = 2000.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var POI : Vector3
var player
var currentState : state = state.IDLE
var vision : Array = []
var see : Array = []
var lastKnowLoc : Vector3

func _ready():
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	$Sprite3D/SubViewport/TextureProgressBar.max_value = MAX_HEALTH
	$Sprite3D/SubViewport/TextureProgressBar.value = health
	player = $"../../Player"

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#move(player.position)
	move_and_slide()

func move(point):
	velocity.x = 0.0
	velocity.y = 0.0
	POI = point
	nav_agent.set_target_position(POI)
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * RUN_SPEED
	elif currentState == state.PATROLLING or currentState == state.IDLE:
		velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * WALK_SPEED

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
		lastKnowLoc = Vector3.ZERO
		for o in see:
			lastKnowLoc += o.global_transform.origin
		lastKnowLoc /= see.size()
