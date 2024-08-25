class_name HitScanGun
extends Gun

const misfireInst = preload("res://Guns/Projectile/Misfire.tscn")

@onready var barrelEnd : Node3D = $BarrelEnd

var flinch : float = 1.0
var rng = RandomNumberGenerator.new()

func startup(object):
	flinch = (object.flinch/20.0)
	super.startup(object)

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		var object = shootRay.get_collider()
		if (object != null):
			print(object.collision_layer)
			if object.collision_layer == 16:
				object = object.get_node("../../../../../../")
				if object.editor_description.contains("Enemy"):
					object.hit(shootRay.get_collision_point(),damage,0)
			elif object.collision_layer == 32:
				object = object.get_node("../../../../../../")
				if object.editor_description.contains("Enemy"):
					object.hit(shootRay.get_collision_point(),damage * critMult,0)
			elif object.collision_layer == 128:
				object.hit(shootRay.get_collision_point(),damage,0)
			elif object.collision_layer == 1:
				var misfire = misfireInst.instantiate()
				get_tree().root.add_child(misfire)
				misfire.look_at(shootRay.get_collision_normal())
				print(misfire.rotation_degrees)
				misfire.global_transform.origin = shootRay.get_collision_point()
		
		get_node("/root/World/Player").recoil(flinch)
		var t = get_tree().create_tween()
		var f = Vector3(\
			rng.randf_range(0.0,flinch)\
			,rng.randf_range(-flinch,flinch)\
			,0.0)
		t.tween_property(barrelEnd,"rotation",barrelEnd.rotation + f,0.2)
		t.tween_property(barrelEnd,"rotation",Vector3(0,0,0),0.5)
		barrelEnd.rotation
		
		chambered = false
		$ShotTimer.start()
	else:
		grace = true
		$GraceTimer.start()
