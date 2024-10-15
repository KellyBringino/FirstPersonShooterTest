extends Enemy_General

func _ready():
	speed = 8.0
	attackDist = 3.5
	$ViewControl/vision/WeaponController/Weapon/Gun.setup(Game.enemyStats.damage, Game.enemyStats.bullet_speed)
	super._ready()
