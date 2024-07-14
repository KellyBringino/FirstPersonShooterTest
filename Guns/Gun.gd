class_name Gun
extends Node3D

const pitchModMax = 0.5

@onready var bSound : AudioStreamPlayer3D = get_node("BarrelEnd/AudioStreamPlayer3D")
@onready var anim : AnimationPlayer = get_node("model/AnimationPlayer")
@onready var ske : Skeleton3D = get_node("model/Armature/Skeleton3D")
@onready var gripBoneAtt : BoneAttachment3D = $model/Armature/Skeleton3D/GripAttachment
@onready var OffBoneAtt : BoneAttachment3D = $model/Armature/Skeleton3D/OffhandAttachment

var damage : float
var critMult : float
var mag : float
var MAG_MAX : float
var chambered : bool = true
var reloading : bool = false

func startup(startDamage, critical, fullMag):
	damage = startDamage
	critMult = critical
	mag = fullMag
	MAG_MAX = fullMag

func _process(_delta):
	$Grip.global_transform.origin = gripBoneAtt.global_transform.origin
	$OffhandGrip.global_transform.origin = OffBoneAtt.global_transform.origin

func fire():
	anim.play("Shoot")
	var modulation = (randf() * pitchModMax) - (pitchModMax/2.0)
	bSound.set_pitch_scale(1.0 + modulation)
	bSound.play()

func singleFire():
	fire()
func heldFire():
	fire()
func releaseFire():
	pass

func reload():
	if mag < MAG_MAX:
		print("reloading " + str(mag))
		reloading = true
		anim.play("Reload")
		print(anim.current_animation)
		await anim.animation_finished
		mag = MAG_MAX
		reloading = false
		print("reloaded " + str(mag))

func _on_shot_timer_timeout():
	chambered = true
