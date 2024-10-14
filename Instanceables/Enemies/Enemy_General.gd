class_name Enemy_General
extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var skl : Skeleton3D = $ModelController/doll/Armature/Skeleton3D
@onready var anim : AnimationPlayer = $ModelController/doll/AnimationPlayer
@onready var healthbar : TextureProgressBar = $Sprite3D/SubViewport/TextureProgressBar
@onready var backbar : TextureProgressBar = $Sprite3D/SubViewport/BackTextureProgressBar
@onready var fireIconContainer = $Sprite3D/SubViewport/IconContainerFire
@onready var iceIconContainer = $Sprite3D/SubViewport/IconContainerIce
@onready var lookTimer = $TimerController/LookCheck
@onready var pathTimer = $TimerController/PathfindTimer
@onready var fireTimer : Timer = $TimerController/FireTimer
@onready var chillTimer : Timer = $TimerController/ChillTimer
@onready var freezeTimer : Timer = $TimerController/FreezeTimer

const RUN_SPEED = 4.0
const REACH_DIST = 0.5
const SHOOT_DIST = 10.0
const STATUS_2_CHANCE = 0.5
const STATUS_3_CHANCE = 1.0/3.0
const COLD_SPEED = 0.20
const COLD_DAMAGE_MULT = 0.05
const HEALTH_BAR_TEXT = preload("res://Assets/Sprites/UI/health.svg")
const HEALTH_BAR_FIRE_TEXT = preload("res://Assets/Sprites/UI/health_fire.svg")

enum state {CHASING, HIDING, SHOOTING}

var currentState : state = state.CHASING
var maxHealth = 2000.0
var health : float = 2000.0
var attackdamage : float = 200.0
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var lastKnowLoc : Vector3
var vision : Array = []
var see : Array = []
var suspicious : bool = false
var fire = 0
var cold = 0
var frozen = false
var shatterRange : Array = []
var dying : bool = false
var player

func _ready():
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	healthbar.max_value = maxHealth
	backbar.max_value = maxHealth
	healthbar.value = health
	backbar.value = health
	player = $"../../Player"
	playAnim("Shoot_Idle",true,false)
	$ViewControl/vision/GunController/Weapon/Gun.setup(Game.enemyStats.damage, Game.enemyStats.bullet_speed)

func startup(h,d,l):
	maxHealth = h
	health = h
	attackdamage = d
	$Sprite3D/SubViewport/LevelLabel.text = "Lvl " + str(l)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#place hands on the gun
	$ViewControl/vision/GunController.global_transform.origin \
	= $ModelController/doll/HandAttachment.global_transform.origin
	
	if !dying and !frozen:
		handleStates(delta)
	
		#look at player
		look_at(lastKnowLoc,Vector3.UP)
		rotation.x = 0.0
		rotation.z = 0.0
	
		#if the player is in the vision cone, look at them and point the gun at them
		if(see.size() > 0):
			$ViewControl.look_at(lastKnowLoc)
			$ViewControl/vision/GunController/Weapon.look_at(lastKnowLoc)
	
	velocity.x = 0
	velocity.z = 0
	if currentState == state.CHASING:
		move()
	else:
		playAnim("Shoot_Idle",true,false)
	move_and_slide()

func handleStates(_delta):
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

func alert(point):
	if currentState == state.CHASING:
		lastKnowLoc = point
		stateChange(state.CHASING)

func move():
	if global_transform.origin.distance_to(lastKnowLoc) <= (REACH_DIST/2.0):
		return
	var nextNavPoint = nav_agent.get_next_path_position()
	if currentState == state.CHASING and !frozen:
		velocity = ((nextNavPoint - global_transform.origin) \
		* Vector3(1,0,1)).normalized() * RUN_SPEED * (1 - (COLD_SPEED * cold))
		playAnim("Run",true,false)

func reached(point):
	var e = Vector2(global_transform.origin.x,global_transform.origin.z)
	var p = Vector2(point.x,point.z)
	var v = e.distance_to(p) <= REACH_DIST
	if v:
		pass
	return v
func distanceCheck(point):
	return global_transform.origin.distance_to(point) <= SHOOT_DIST

func stateChange(nState):
	match nState:
		state.CHASING:
			currentState = state.CHASING
			suspicious = true
		state.SHOOTING:
			currentState = state.SHOOTING
			suspicious = true

func damage(point, amount, source):
	if source != 2:
		health -= amount * (1 +  (cold * COLD_DAMAGE_MULT))
	else:
		health -= amount
	backbar.max_value = maxHealth
	var t = get_tree().create_tween()
	t.tween_property(backbar,"value",health,0.5)
	healthbar.value = health
	healthbar.max_value = maxHealth
	if health <= 0:
		dead(point,source)
func hit(point, d, source):
	if frozen:
		for part in shatterRange:
			if part != self:
				part.hit(part.global_position,d,3)
		frozen = false
	damage(point,d,source)
func burn(t):
	healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
	match fire:
		0:
			fire += 1
			fireIconContainer.get_child(0).show()
			fireIconContainer.get_child(1).hide()
			fireIconContainer.get_child(2).hide()
		1:
			if randf() < STATUS_2_CHANCE:
				fire += 1
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).show()
				fireIconContainer.get_child(2).hide()
		2:
			if randf() < STATUS_3_CHANCE:
				fire += 1
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).show()
				fireIconContainer.get_child(2).show()
		3:
			fireIconContainer.get_child(0).show()
			fireIconContainer.get_child(1).show()
			fireIconContainer.get_child(2).show()
	fireTimer.wait_time = t
	fireTimer.start()
func chill(t):
	healthbar.tint_over = Color(1.0,1.0,1.0,1.0)
	match cold:
		0:
			cold += 1
			iceIconContainer.get_child(0).show()
			iceIconContainer.get_child(1).hide()
			iceIconContainer.get_child(2).hide()
		1:
			if randf() < STATUS_2_CHANCE:
				cold += 1
				iceIconContainer.get_child(0).show()
				iceIconContainer.get_child(1).show()
				iceIconContainer.get_child(2).hide()
		2:
			if randf() < STATUS_3_CHANCE:
				cold += 1
				iceIconContainer.get_child(0).show()
				iceIconContainer.get_child(1).show()
				iceIconContainer.get_child(2).show()
		3:
			iceIconContainer.get_child(0).show()
			iceIconContainer.get_child(1).show()
			iceIconContainer.get_child(2).show()
			pass
	if !frozen:
		anim.speed_scale = (1 - (COLD_SPEED * cold))
	chillTimer.wait_time = t
	chillTimer.start()
func freeze(t):
	frozen = true
	anim.speed_scale = 0
	freezeTimer.wait_time = t
	freezeTimer.start()
func strike(object,point,damage):
	if object.collision_layer == 16 or object.collision_layer == 32:
		while !object.editor_description.contains("Enemy"):
			if object == null:
				break
			if object == self:
				object == null
				break
			object = object.get_node("../")
		if object != null:
			if object.editor_description.contains("Enemy"):
				object.hit(point,damage,0)
	elif object.collision_layer == 128:
		object.hit(point,damage,0)

func dead(_point, source):
	if !dying:
		dying = true
		match source:
			0:#hitscan
				$"../../".enemydeath(0)
				queue_free()
			1:#explosion
				$"../../".enemydeath(0)
				queue_free()
			2:#fire
				$"../../".enemydeath(0)
				queue_free()

func playAnim(n,_looping,_override):
	anim.play(n)

func _on_vision_body_entered(body):
	if body.collision_layer == 8:
		vision.append(body)

func _on_vision_body_exited(body):
	for index in vision.size():
		if vision[index] == body:
			vision.remove_at(index)
			break

func _on_shatter_area_body_entered(body):
	shatterRange.append(body)
func _on_shatter_area_body_exited(body):
	for index in shatterRange.size():
		if shatterRange[index] == body:
			shatterRange.remove_at(index)
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
	else:
		lastKnowLoc = player.global_transform.origin

func _on_pathfind_timer_timeout():
	nav_agent.set_target_position(lastKnowLoc)

func _on_shoot_timer_timeout():
	if currentState == state.SHOOTING:
		$ViewControl/vision/GunController/Weapon/Gun.shoot()

func _on_tick_timer_timeout():
	if fire > 0:
		healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
		damage(global_position,(maxHealth * fire)/(30.0),2)
	else:
		healthbar.texture_progress = HEALTH_BAR_TEXT

func _on_chill_timer_timeout():
	if cold > 0:
		cold -= 1
		match cold:
			0:
				healthbar.tint_over = Color(1.0,1.0,1.0,0.0)
				iceIconContainer.get_child(0).hide()
				iceIconContainer.get_child(1).hide()
				iceIconContainer.get_child(2).hide()
			1:
				healthbar.tint_over = Color(1.0,1.0,1.0,1.0)
				iceIconContainer.get_child(0).show()
				iceIconContainer.get_child(1).hide()
				iceIconContainer.get_child(2).hide()
				chillTimer.start()
			2:
				healthbar.tint_over = Color(1.0,1.0,1.0,1.0)
				iceIconContainer.get_child(0).show()
				iceIconContainer.get_child(1).show()
				iceIconContainer.get_child(2).hide()
				chillTimer.start()
	anim.speed_scale = (1 - (COLD_SPEED * cold))

func _on_fire_timer_timeout():
	if fire > 0:
		fire -= 1
		match fire:
			0:
				fireIconContainer.get_child(0).hide()
				fireIconContainer.get_child(1).hide()
				fireIconContainer.get_child(2).hide()
			1:
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).hide()
				fireIconContainer.get_child(2).hide()
				fireTimer.start()
			2:
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).show()
				fireIconContainer.get_child(2).hide()
				fireTimer.start()


func _on_freeze_timer_timeout():
	frozen = false
	anim.speed_scale = (1 - (COLD_SPEED * cold))
