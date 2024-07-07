extends ProjectileGun

const rocketInstance = preload("res://Guns/Projectile/rocket.tscn")

func _ready():
	pstartup(200,rocketInstance,1)

func heldFire():
	pass
