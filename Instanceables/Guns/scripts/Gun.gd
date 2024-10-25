class_name Gun
extends Node3D

const pitchModMax = 0.5
const fireRing = preload("res://Instanceables/Guns/Projectile/FireAOE.tscn")
const misfireInst = preload("res://Instanceables/Guns/Projectile/Misfire.tscn")

@onready var bSound : AudioStreamPlayer3D = \
	get_node("BarrelEnd/AudioStreamPlayer3D")
@onready var anim : AnimationPlayer = get_node("model/AnimationPlayer")
@onready var ske : Skeleton3D = get_node("model/Armature/Skeleton3D")
@onready var gripBoneAtt : BoneAttachment3D = \
	$model/Armature/Skeleton3D/GripAttachment
@onready var OffBoneAtt : BoneAttachment3D = \
	$model/Armature/Skeleton3D/OffhandAttachment
@onready var shootRay : RayCast3D = $BarrelEnd/ShootRay
@onready var aoeTrigger : Area3D = $AOETrigger

var damageLevel : int = 0
var magLevel : int = 0
var fireWeapon : bool = false
var iceWeapon : bool = false

var damage : float
var critMult : float
var mag : int
var MAG_MAX : int
var reserve : int
var reserveMax : int
var gunType : int
var reloadMult : float
var ammoCost : float
var damageUpgradeCost : float
var damageUpgrade : float
var magUpgradeCost : float
var magUpgrade : int
var elementalUpgradeCost : float
var spreadingWeapon : bool
var adsOffset : float
var adsZoom : float
var limited : bool = false
var chambered : bool = true
var reloading : bool = false
var grace : bool = false
var scope : bool = false
var inRange = []

func startup(object):
	gunType = object.gunType
	damage = object.damage
	critMult = object.crit
	mag = object.magsize
	MAG_MAX = object.magsize
	damageUpgradeCost = object.upgradeCost
	damageUpgrade = object.damageUpgrade
	magUpgradeCost = object.magUpgradeCost
	magUpgrade = object.magUpgrade
	elementalUpgradeCost = object.elementalUpgradeCost
	spreadingWeapon = object.spreadingWeapon
	reloadMult = object.reloadMult
	adsOffset = object.adsOffset / 10.0
	adsZoom = object.adsZoom
	scope = object.scope
	if object.ammoLimited:
		limited = true
		reserveMax = object.ammoMax
		reserve = object.ammoMax
		ammoCost = object.ammoCost

func _process(_delta):
	$Grip.global_transform.origin = gripBoneAtt.global_transform.origin
	$OffhandGrip.global_transform.origin = OffBoneAtt.global_transform.origin

func fire():
	var enemies = get_node("/root/World/Enemies").get_children()
	for e in enemies:
		if global_transform.origin.\
		distance_to(e.global_transform.origin) < 50.0:
			e.alert(global_transform.origin)
	anim.stop()
	anim.play("Shoot")
	var modulation = (randf() * pitchModMax) - (pitchModMax/2.0)
	bSound.set_pitch_scale(1.0 + modulation)
	bSound.play()
	grace = false

func singleFire():
	fire()
func heldFire():
	fire()
func releaseFire():
	pass

func reload():
	if mag < MAG_MAX && !(limited && reserve==0):
		reloading = true
		anim.play("Reload",-1,reloadMult,false)
		if scope:
			get_node("/root/World/Player").releaseADS()
		await anim.animation_finished
		if limited:
			if reserve < MAG_MAX:
				mag = reserve
				reserve = 0
			else:
				reserve -= MAG_MAX - mag
				mag = MAG_MAX
		else:
			mag = MAG_MAX
		reloading = false
		if grace:
			fire()

func getReserveDiff():
	return reserveMax - reserve
func fillReserve():
	reserve = reserveMax

func upgradeDamage():
	if checkDamageLevel():
		damage += damageUpgrade
		damageLevel += 1
func checkDamageLevel():
	return damageLevel < 5

func upgradeMag():
	if checkMagLevel():
		MAG_MAX += magUpgrade
		mag += magUpgrade
		reserveMax += magUpgrade * 2
		reserve += magUpgrade * 2
		magLevel += 1
func checkMagLevel():
	return magLevel < 3

func upgradeFire():
	fireWeapon = true
func upgradeIce():
	iceWeapon = true
func checkElement():
	if fireWeapon:
		return 1
	if iceWeapon:
		return 2
	return 0

func _on_shot_timer_timeout():
	chambered = true
	if grace:
		fire()

func _on_grace_timer_timeout():
	grace = false

func _on_aoe_trigger_body_entered(body):
	inRange.append(body)
func _on_aoe_trigger_body_exited(body):
	for index in inRange.size():
		if inRange[index] == body:
			inRange.remove_at(index)
			break

func strike(object):
	var point = shootRay.get_collision_point()
	var dam = damage
	if object.collision_layer == 16 or object.collision_layer == 32:
		while !object.editor_description.contains("Enemy"):
			if object == null:
				break
			object = object.get_node("../")
		if object != null:
			if object.collision_layer == 32:
				dam *= critMult
	
	#if hit object is environment, make misfire
	if object.collision_layer == 1:
		var misfire = misfireInst.instantiate()
		get_tree().root.add_child(misfire)
		misfire.global_transform.origin = shootRay.get_collision_point()
	else:#if hit object is not environment do elemental effects
		if fireWeapon and spreadingWeapon:
			object.burn(5)
		elif iceWeapon and spreadingWeapon:
			object.chill(10)
		elif iceWeapon:
			object.freeze(15)
		
		object.hit(point,dam,0)
	
	if fireWeapon and !spreadingWeapon:
		var misfire = fireRing.instantiate()
		get_tree().root.add_child(misfire)
		misfire.global_transform.origin = shootRay.get_collision_point()
		misfire.setup(aoeTrigger.get_child(0).shape.radius)
		aoeTrigger.global_position = point
		aoeTrigger.force_update_transform()
		var hits = []
		for o in inRange:
			while !o.editor_description.contains("Enemy"):
					if o == null:
						break
					o = o.get_node("../")
			if o != null and !hits.has(o):
				hits.append(o)
		for o in hits:
			o.hit(point,dam,1)
