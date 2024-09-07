extends Node

enum GunType {NONE, RIFLE, SNIPER, PISTOL, REVOLVER, ROCKETLAUNCHER}


const pistolInstance = preload("res://Guns/pistol.tscn")
const rifleInstance = preload("res://Guns/rifle.tscn")
const sniperInstance = preload("res://Guns/sniper.tscn")
const revolverInstance = preload("res://Guns/revolver.tscn")
const rocketlauncherInstance = preload("res://Guns/rocketlauncher.tscn")

const rocketInstance = preload("res://Guns/Projectile/rocket.tscn")

const enemyStats = \
{\
	health = 2000.0,\
	damage = 200.0,\
	bullet_speed = 4.0,\
	partCount = 20\
}
const playerStats = \
{\
	health = 2000.0,\
	healthCost = 0.1\
}

#primary stats
const rifle = \
{\
	name = "rifle", \
	ammoLimited = true,\
	damage = 350.0, \
	crit = 1.3, \
	magsize = 40, \
	ammoMax = 240,\
	reloadMult = 1.0,\
	flinch = 0.2,\
	adsOffset = -0.5,\
	adsZoom = 50.0,\
	scope = false,\
	ammoCost = 1.0,\
	upgradeCost = 600,\
	magUpgradeCost = 400\
}
const sniper = \
{\
	name = "sniper", \
	ammoLimited = true,\
	damage = 1000.0, \
	crit = 2.0, \
	magsize = 3, \
	ammoMax = 18,\
	reloadMult = 1.0,\
	flinch = 1.0,\
	adsOffset = 0.0,\
	adsZoom = 20.0,\
	scope = true,\
	ammoCost = 20.0,\
	upgradeCost = 600,\
	magUpgradeCost = 800\
}
#secondary stats
const pistol = \
{\
	name = "pistol", \
	ammoLimited = false,\
	damage = 300.0, \
	crit = 1.5, \
	magsize = 10, \
	reloadMult = 1.0,\
	flinch = 0.2,\
	adsOffset = 0.0,\
	adsZoom = 60.0,\
	scope = false,\
	upgradeCost = 400,\
	magUpgradeCost = 400\
}
const revolver = \
{\
	name = "revolver", \
	ammoLimited = false,\
	damage = 550.0, \
	crit = 1.7, \
	magsize = 6, \
	reloadMult = 1.3,\
	flinch = 0.8,\
	adsOffset = 0.0,\
	adsZoom = 50.0,\
	scope = false,\
	upgradeCost = 400,\
	magUpgradeCost = 600\
}
#heavy stats
const rocketlauncher = \
{\
	name = "rocketlauncher", \
	ammoLimited = true,\
	damage = 300.0, \
	crit = 1.0, \
	magsize = 1, \
	ammoMax = 4,\
	reloadMult = 1.0,\
	flinch = 0.0,\
	adsOffset = 0.0,\
	adsZoom = 50.0,\
	scope = true,\
	ammoCost = 40.0,\
	upgradeCost = 1000,\
	proj = rocketInstance\
}

var paused : bool = false
var horizontalSensitivity = 0.8
var verticalSensitivity = 0.8
var score : int = 0
var weapons = [GunType.RIFLE,GunType.REVOLVER,GunType.ROCKETLAUNCHER]

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	paused = !paused
	if paused:
		StartUI()
		$"../World/GUI".pause()
	else:
		StartLevel()
		$"../World/GUI".unpause()

func resume():
	paused = false
	if get_node_or_null("../World/GUI") != null:
		$"../World/GUI".unpause()
	StartLevel()

func StartLevel():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func StartUI():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func playerReady():
	var player = $"../World/Player"
	player.setSens(horizontalSensitivity,verticalSensitivity)
	player.setHealth(2000.0)
	
	if weapons[0] == GunType.RIFLE:
		var riflegun = rifleInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(riflegun)
	elif weapons[0] == GunType.SNIPER:
		var snipergun = sniperInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(snipergun)
	
	if weapons[1] == GunType.PISTOL:
		var pistolgun = pistolInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2"\
			.add_child(pistolgun)
	elif weapons[1] == GunType.REVOLVER:
		var revolvergun = revolverInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2"\
			.add_child(revolvergun)
	
	if weapons[2] == GunType.ROCKETLAUNCHER:
		var rocketgun = rocketlauncherInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon3"\
			.add_child(rocketgun)
	
	player.setGuns(weapons)
	$"../World/GUI".setWeapons(weapons)

func choose(pri,sec,hea):
	match pri:
		0:
			weapons[0] = GunType.NONE
		1:
			weapons[0] = GunType.RIFLE
		2:
			weapons[0] = GunType.SNIPER
	
	match sec:
		0:
			weapons[1] = GunType.NONE
		1:
			weapons[1] = GunType.PISTOL
		2:
			weapons[1] = GunType.REVOLVER
	
	match hea:
		0:
			weapons[2] = GunType.NONE
		1:
			weapons[2] = GunType.ROCKETLAUNCHER

func equip(hea,pri):
	$"../World/GUI".equip(hea,pri)

func pauseCheck():
	return paused
