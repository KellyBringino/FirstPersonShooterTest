class_name Gun
extends Node3D

@onready var shootRay: RayCast3D = get_node("BarrelEnd/ShootRay")
@onready var anim : AnimationPlayer = get_node("model/AnimationPlayer")

var damage : float
var mag : float
var MAG_MAX : float
var chambered : bool = true
var reloading : bool = false

func startup(startDamage, startMag, fullMag):
	damage = startDamage
	mag = startMag
	MAG_MAX = fullMag

func fire():
	if chambered && !reloading && mag > 0:
		anim.play("Shoot")
		mag -= 1
		var object = shootRay.get_collider()
		if (object != null):
			#print("hit a " + str(object))
			if object.editor_description.contains("Enemy"):
				object.hit(shootRay.get_collision_point(),damage)
		chambered = false
		$ShotTimer.start()

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
