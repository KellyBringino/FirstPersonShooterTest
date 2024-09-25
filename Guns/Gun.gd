class_name Gun
extends Node3D

const pitchModMax = 0.5

@onready var bSound : AudioStreamPlayer3D = \
	get_node("BarrelEnd/AudioStreamPlayer3D")
@onready var anim : AnimationPlayer = get_node("model/AnimationPlayer")
@onready var ske : Skeleton3D = get_node("model/Armature/Skeleton3D")
@onready var gripBoneAtt : BoneAttachment3D = \
	$model/Armature/Skeleton3D/GripAttachment
@onready var OffBoneAtt : BoneAttachment3D = \
	$model/Armature/Skeleton3D/OffhandAttachment
@onready var shootRay : RayCast3D = $BarrelEnd/ShootRay

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
var magUpgrade : float
var adsOffset : float
var adsZoom : float
var limited : bool = false
var chambered : bool = true
var reloading : bool = false
var grace : bool = false
var scope : bool = false

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
	return damageLevel <= 5

func upgradeMag():
	if checkMagLevel():
		MAG_MAX += magUpgrade
		mag += magUpgrade
		magLevel += 1
func checkMagLevel():
	return magLevel <= 3

func _on_shot_timer_timeout():
	chambered = true
	if grace:
		fire()

func _on_grace_timer_timeout():
	grace = false
