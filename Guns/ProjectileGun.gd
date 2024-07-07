class_name ProjectileGun
extends Gun

var projectile

func pstartup(startDamage, proj, fullMag):
	damage = startDamage
	projectile = proj
	mag = fullMag
	MAG_MAX = fullMag
	startup(startDamage,1.0,fullMag)

func fire():
	if chambered && !reloading && mag > 0:
		super.fire()
		mag -= 1
		var proj = projectile.instantiate()
		get_tree().root.get_child(0).add_child(proj)
		proj.global_position = $BarrelEnd.global_position
		proj.global_rotation = $BarrelEnd.global_rotation
		proj.velocity = proj.global_transform.basis.z
		chambered = false
		$ShotTimer.start()
