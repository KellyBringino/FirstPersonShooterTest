extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var health = 2000.0

const MAX_HEALTH = 2000.0
const SPEED = 4.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var POI : Vector3
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
	velocity.x = 0.0
	velocity.y = 0.0
	POI = player.position
	nav_agent.set_target_position(POI)
	var nextNavPoint = nav_agent.get_next_path_position()
	velocity = ((nextNavPoint - global_transform.origin) * Vector3(1,0,1)).normalized() * SPEED
	move_and_slide()
	
func damage(amount):
	health -= amount
	$Sprite3D/SubViewport/TextureProgressBar.value = health

func hit(point, damage):
	print(str(health))
	damage(damage)
