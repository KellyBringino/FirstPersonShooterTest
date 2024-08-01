class_name HitScanGun
extends Gun

@onready var shootRay: RayCast3D = get_node("BarrelEnd/ShootRay")

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		var object = shootRay.get_collider()
		if (object != null):
			if object.collision_layer == 16:
				object = object.get_node("../../../../../../")
				if object.editor_description.contains("Enemy") || object.editor_description.contains("Dest"):
					object.hit(shootRay.get_collision_point(),damage,0)
			elif object.collision_layer == 32:
				object = object.get_node("../../../../../../")
				if object.editor_description.contains("Enemy") :
					object.hit(shootRay.get_collision_point(),damage * critMult,0)
			elif object.collision_layer == 128:
				object.hit(shootRay.get_collision_point(),damage,0)
		chambered = false
		$ShotTimer.start()
	else:
		grace = true
		$GraceTimer.start()
