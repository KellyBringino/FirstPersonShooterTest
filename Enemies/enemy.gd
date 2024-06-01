extends CharacterBody3D

var health = 200.0

const MAX_HEALTH = 200.0
const SPEED = 4.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	$Sprite3D/SubViewport/TextureProgressBar.max_value = MAX_HEALTH
	$Sprite3D/SubViewport/TextureProgressBar.value = health

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	
func damage(amount):
	health -= amount
	$Sprite3D/SubViewport/TextureProgressBar.value = health

func hit(point, damage):
	print(str(health))
	damage(damage)
