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
@onready var attackTimer = $TimerController/AttackTimer
@onready var fireTimer : Timer = $TimerController/FireTimer
@onready var fireEffect : GPUParticles3D = $ModelController/Fire
@onready var chillTimer : Timer = $TimerController/ChillTimer
@onready var freezeTimer : Timer = $TimerController/FreezeTimer
@onready var freezeImmuneTimer : Timer = $TimerController/FreezeImmuneTimer
@onready var iceEffect : GPUParticles3D = $ModelController/Ice

const REACH_DIST = 0.5
const STATUS_2_CHANCE = 0.5
const STATUS_3_CHANCE = 1.0/3.0
const COLD_SPEED = 0.20
const COLD_DAMAGE_MULT = 0.05
const HEALTH_BAR_TEXT = preload("res://Assets/Sprites/UI/health.svg")
const HEALTH_BAR_FIRE_TEXT = preload("res://Assets/Sprites/UI/health_fire.svg")

enum state {CHASING, HIDING, ATTACKING}

var speed = 4.0
var attackDist = 10.0
var attackGrace = false
var moveDist = 12.0
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
var freezeImmunity = false
var shatterRange : Array = []
var dying : bool = false
var player

func _ready():
	$Sprite3D.texture = $Sprite3D/SubViewport.get_texture()
	healthbar.max_value = maxHealth
	backbar.max_value = maxHealth
	healthbar.value = health
	backbar.value = health
	fireEffect.emitting = false
	iceEffect.emitting = false
	player = $"../../Player"
	playAnim("Attack_Idle",false)

func startup(h,d,l,_object):
	maxHealth = h
	health = h
	attackdamage = d
	healthbar.max_value = maxHealth
	backbar.max_value = maxHealth
	healthbar.value = health
	backbar.value = health
	$Sprite3D/SubViewport/LevelLabel.text = "Lvl " + str(l)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#place weapon in hands
	$ViewControl/vision/WeaponController.global_transform.origin \
	= $ModelController/doll/HandAttachment.global_transform.origin
	
	if !dying and !frozen:
		nav_agent.set_target_position(lastKnowLoc)
		handleStates(delta)
	
		#look at player
		look_at(lastKnowLoc,Vector3.UP)
		rotation.x = 0.0
		rotation.z = 0.0
		
		#if the player is in the vision cone, look at them and point the gun at them
		if(see.size() > 0):
			$ViewControl.look_at(lastKnowLoc)
			$ViewControl/vision/WeaponController/Weapon.look_at(lastKnowLoc)
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
			if currentState == state.CHASING:
				move()
			elif currentState == state.ATTACKING:
				playAnim("Attack_Idle",false)
		else:
			playAnim("Attack_Idle",false)
	move_and_slide()

func handleStates(_delta):
	match currentState:
		state.CHASING:
			if see.size() > 0 and distanceCheck(lastKnowLoc,attackDist):
				stateChange(state.ATTACKING)
				if attackGrace:
					attack()
					attackGrace = false
					attackTimer.start()
			elif see.size() == 0 \
			and distanceCheck(player.global_transform.origin,attackDist):
				look_at(player.position,Vector3.UP)
				rotation.x = 0.0
				rotation.z = 0.0
			elif reached(lastKnowLoc):
				stateChange(state.ATTACKING)
			else:
				lastKnowLoc = player.global_transform.origin
		state.ATTACKING:
			if !distanceCheck(lastKnowLoc,moveDist):
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
	if !frozen:
		velocity = ((nextNavPoint - global_transform.origin) \
		* Vector3(1,0,1)).normalized() * speed * (1 - (COLD_SPEED * cold))
		playAnim("Run",false)

func reached(point):
	var e = Vector2(global_transform.origin.x,global_transform.origin.z)
	var p = Vector2(point.x,point.z)
	var v = e.distance_to(p) <= REACH_DIST
	if v:
		pass
	return v
func distanceCheck(point,dist):
	return global_transform.origin.distance_to(point) <= dist

func stateChange(nState):
	match nState:
		state.CHASING:
			currentState = state.CHASING
			suspicious = true
		state.ATTACKING:
			currentState = state.ATTACKING
			suspicious = true

func setAnimSpeed():
	anim.speed_scale = (1 - (COLD_SPEED * cold)) * (speed/2.0)

func damage(point, amount, source):
	if source != 2:
		health -= amount * (1 +  (cold * COLD_DAMAGE_MULT))
	else:
		health -= amount
	backbar.max_value = maxHealth
	var t = get_tree().create_tween()
	t.bind_node(self)
	t.tween_property(backbar,"value",health,0.5)
	healthbar.value = health
	healthbar.max_value = maxHealth
	if health <= 0:
		dead(point,source)
func hit(point, d, source):
	if frozen:
		shatter()
	damage(point,d,source)
func burn(t):
	healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
	fireEffect.emitting = true
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
		setAnimSpeed()
	chillTimer.wait_time = t
	chillTimer.start()
func freeze(t):
	if freezeImmuneTimer.is_stopped():
		frozen = true
		iceEffect.emitting = true
		anim.speed_scale = 0
		freezeTimer.wait_time = t
		freezeTimer.start()
func shatter():
	var iceEx = Game.iceAOEPreload.instantiate()
	add_child(iceEx)
	iceEx.position += Vector3(0,1,0)
	iceEx.setup($ShatterArea/CollisionShape3D.shape.radius)
	frozen = false
	iceEffect.emitting = false
	for part in shatterRange:
		if part != self:
			part.hit(part.global_position,maxHealth/3,3)
	setAnimSpeed()
	freezeImmuneTimer.start()

func attack():
	playAnim("Attack",true)
	$ViewControl/vision/WeaponController/Weapon/Gun.shoot()

func dead(_point, source):
	if !dying:
		dying = true
		var rag = Game.enemyRagdollPreload.instantiate()
		get_node("/root/World").add_child(rag)
		rag.global_transform.basis = global_transform.basis
		rag.global_position = global_position
		rag.rotation = rotation
		rag.scale = $ModelController/doll.scale
		var skele = $ModelController/doll/Armature/Skeleton3D
		for bone in 36:
			rag.skel.set_bone_pose_position(bone,skele.get_bone_pose_position(bone))
			rag.skel.set_bone_pose_rotation(bone,skele.get_bone_pose_rotation(bone))
		rag.setup(source,get_node("/root/World"))
		if frozen:
			shatter()
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
			3:#ice
				$"../../".enemydeath(0)
				queue_free()
				

func playAnim(n,override):
	if override or !anim.is_playing():
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

func _on_attack_timer_timeout():
	if currentState == state.ATTACKING:
		attack()
	else:
		attackGrace = true
		attackTimer.stop()

func _on_tick_timer_timeout():
	if fire > 0:
		healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
		fireEffect.emitting = true
		damage(global_position,(maxHealth * fire)/(30.0),2)
	else:
		healthbar.texture_progress = HEALTH_BAR_TEXT
		fireEffect.emitting = false

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
	setAnimSpeed()

func _on_fire_timer_timeout():
	if fire > 0:
		fire -= 1
		match fire:
			0:
				fireIconContainer.get_child(0).hide()
				fireIconContainer.get_child(1).hide()
				fireIconContainer.get_child(2).hide()
				healthbar.texture_progress = HEALTH_BAR_TEXT
				fireEffect.emitting = false
			1:
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).hide()
				fireIconContainer.get_child(2).hide()
				healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
				fireEffect.emitting = true
				fireTimer.start()
			2:
				fireIconContainer.get_child(0).show()
				fireIconContainer.get_child(1).show()
				fireIconContainer.get_child(2).hide()
				healthbar.texture_progress = HEALTH_BAR_FIRE_TEXT
				fireEffect.emitting = true
				fireTimer.start()

func _on_freeze_timer_timeout():
	frozen = false
	iceEffect.emitting = false
	setAnimSpeed()
func _on_freeze_immune_timer_timeout():
	pass # Replace with function body.
