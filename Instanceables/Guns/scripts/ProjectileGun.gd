class_name ProjectileGun
extends Gun

var projectile

func pstartup(object):
	damage = object.damage
	projectile = object.proj
	mag = object.magsize
	MAG_MAX = object.magsize
	startup(object)

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		var proj = projectile.instantiate()
		get_tree().root.get_child(0).add_child(proj)
		proj.global_position = $BarrelEnd.global_position
		proj.global_rotation = $BarrelEnd.global_rotation
		proj.linear_velocity += -proj.global_transform.basis.z * 15
		proj.setup(damage,fireWeapon,iceWeapon)
		chambered = false
		$ShotTimer.start()
