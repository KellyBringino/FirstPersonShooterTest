extends ProjectileGun

const rocketInstance = preload("res://Guns/Projectile/rocket.tscn")

func _ready():
	pstartup(300,rocketInstance,1)

func heldFire():
	pass
