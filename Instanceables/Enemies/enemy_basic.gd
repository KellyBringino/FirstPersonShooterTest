extends Enemy_General

func _ready():
	$ViewControl/vision/WeaponController/Weapon/Gun.setup(Game.enemyStats.damage, Game.enemyStats.bullet_speed)
	super._ready()

