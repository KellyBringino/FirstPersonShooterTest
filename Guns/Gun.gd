class_name Gun
extends Node3D

const pitchModMax = 0.5

@onready var bSound : AudioStreamPlayer3D = get_node("BarrelEnd/AudioStreamPlayer3D")
@onready var anim : AnimationPlayer = get_node("model/AnimationPlayer")

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
