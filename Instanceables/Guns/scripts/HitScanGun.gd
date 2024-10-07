class_name HitScanGun
extends Gun

const misfireInst = preload("res://Instanceables/Guns/Projectile/Misfire.tscn")
const bulletInst = preload("res://Instanceables/Guns/Projectile/bullet_particle.tscn")

@onready var barrelEnd : Node3D = $BarrelEnd
@onready var aoeTrigger : Area3D = $AOETrigger

var flinch : float = 1.0
var rng = RandomNumberGenerator.new()

func startup(object):
	flinch = (object.flinch/20.0)
	super.startup(object)

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		shootRay.force_raycast_update()
		var object = shootRay.get_collider()
		if (object != null):
			var bullet = bulletInst.instantiate()
			get_tree().root.add_child(bullet)
			bullet.global_transform.origin = shootRay.global_transform.origin
			bullet.global_rotation = shootRay.global_rotation
			var dist = shootRay.global_transform.origin.distance_to\
				(shootRay.get_collision_point())
			bullet.startup(dist)
			#print(object.collision_layer)
			if object.collision_layer == 16:
				while !object.editor_description.contains("Enemy"):
					if object == null:
						break
					object = object.get_node("../")
				if object != null:
					if object.editor_description.contains("Enemy"):
						strike(object,false)
			elif object.collision_layer == 32:
				while !object.editor_description.contains("Enemy"):
					if object == null:
						break
					object = object.get_node("../")
				if object != null:
					if object.editor_description.contains("Enemy"):
						strike(object,true)
			elif object.collision_layer == 128:
				strike(object,false)
			elif object.collision_layer == 1:
				var misfire = misfireInst.instantiate()
				get_tree().root.add_child(misfire)
				misfire.global_transform.origin = shootRay.get_collision_point()
		else:
			var bullet = bulletInst.instantiate()
			get_tree().root.add_child(bullet)
			bullet.global_position = barrelEnd.global_position
			bullet.global_rotation = barrelEnd.global_rotation
			bullet.startup(100)
		
		get_node("/root/World/Player").recoil(flinch)
		var t = get_tree().create_tween()
		var f = Vector3(\
			rng.randf_range(0.0,flinch)\
			,rng.randf_range(-flinch,flinch)\
			,0.0)
		t.tween_property(barrelEnd,"rotation",barrelEnd.rotation + f,0.2)
		t.tween_property(barrelEnd,"rotation",Vector3(0,0,0),0.5)
		
		chambered = false
		$ShotTimer.start()
	else:
		grace = true
		$GraceTimer.start()

func strike(obj,crit):
	var dam = damage
	var point = shootRay.get_collision_point()
	if crit:
		dam *= critMult
	obj.hit(point,dam,0)
	if fireWeapon and fastFiring:
		obj.burn(5)
	elif fireWeapon:
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
	elif iceWeapon and fastFiring:
		pass
	elif iceWeapon:
		pass
