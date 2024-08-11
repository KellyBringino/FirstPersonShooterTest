class_name HitScanGun
extends Gun

const misfireInst = preload("res://Guns/Projectile/Misfire.tscn")

@onready var shootRay: RayCast3D = get_node("BarrelEnd/ShootRay")

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		var object = shootRay.get_collider()
		print(object.collision_layer)
		if (object != null):
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
		chambered = false
		$ShotTimer.start()
	else:
		grace = true
		$GraceTimer.start()
