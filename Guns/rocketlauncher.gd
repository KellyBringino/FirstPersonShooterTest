extends ProjectileGun

const rocketInstance = preload("res://Guns/Projectile/rocket.tscn")

func _ready():
	pstartup(Game.rocketlauncherDamage,rocketInstance,1)

func heldFire():
	pass
