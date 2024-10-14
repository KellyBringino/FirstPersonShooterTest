extends Node

enum GunType {
	NONE, 
	RIFLE, SNIPER, SHOTGUN, 
	PISTOL, REVOLVER, SMG, 
	ROCKETLAUNCHER, GRENADELAUNCHER
}

const enemyStats = \
{\
	health = 2000.0,\
	damage = 200.0,\
	bullet_speed = 4.0,\
	levelHealth = 80,\
	partCount = 20\
}
const playerStats = \
{\
	health = 2000.0,\
	healthCost = 0.1\
}

#primary stats
const rifle = {
	name = "Rifle", ammoLimited = true, gunType = 1,
	damage = 770.0, crit = 1.3, 
	magsize = 40, ammoMax = 240, reloadMult = 1.0,
	flinch = 0.2, adsOffset = -0.5,
	adsZoom = 50.0, scope = false,
	ammoCost = 1.0, upgradeCost = 600, magUpgradeCost = 400, elementalUpgradeCost = 1000,
	damageUpgrade = 500, magUpgrade = 80, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/rifle.tscn")
}
const sniper = {
	name = "Sniper Rifle", ammoLimited = true, gunType = 1,
	damage = 2500.0, crit = 2.0, 
	magsize = 3, ammoMax = 18, reloadMult = 1.0,
	flinch = 1.0, adsOffset = 0.0,
	adsZoom = 20.0, scope = true,
	ammoCost = 20.0, upgradeCost = 600, magUpgradeCost = 800, elementalUpgradeCost = 1000,
	damageUpgrade = 500, magUpgrade = 2, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/sniper.tscn")
}
const shotgun = {
	name = "Shotgun", ammoLimited = true, gunType = 1,
	damage = 700.0, crit = 1.3, 
	magsize = 5, ammoMax = 50, reloadMult = 1.0,
	pellets = 60, rings = 10,
	flinch = 1.0, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 20.0, upgradeCost = 600, magUpgradeCost = 800, elementalUpgradeCost = 1000,
	damageUpgrade = 520, magUpgrade = 2, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/shotgun.tscn")
}
#secondary stats
const pistol = {
	name = "Pistol", ammoLimited = false, gunType = 0,
	damage = 445.0, crit = 1.5, 
	magsize = 10, reloadMult = 1.0,
	flinch = 0.2, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 0, upgradeCost = 1, magUpgradeCost = 1, elementalUpgradeCost = 1,
	damageUpgrade = 255, magUpgrade = 3, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/pistol.tscn")
}
const revolver = {
	name = "Revolver", ammoLimited = false, gunType = 0,
	damage = 550.0, crit = 1.7, 
	magsize = 6, reloadMult = 1.3,
	flinch = 0.8, adsOffset = 0.0,
	adsZoom = 50.0, scope = false,
	ammoCost = 0, upgradeCost = 400, magUpgradeCost = 600, elementalUpgradeCost = 1000,
	damageUpgrade = 370, magUpgrade = 2, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/revolver.tscn")
}
const smg = {
	name = "SMG", ammoLimited = false, gunType = 0,
	damage = 200.0, crit = 1.3, 
	magsize = 20, reloadMult = 1.0,
	flinch = 0.4, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 0, upgradeCost = 1, magUpgradeCost = 1, elementalUpgradeCost = 1,
	damageUpgrade = 150, magUpgrade = 5, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/smg.tscn")
}
#heavy stats
const rocketlauncher = {
	name = "Rocket Launcher", ammoLimited = true, gunType = 2,
	damage = 150.0, crit = 1.0, 
	magsize = 1, ammoMax = 4, reloadMult = 1.0,
	flinch = 0.0, adsOffset = 0.0,
	adsZoom = 50.0, scope = true,
	ammoCost = 40.0, upgradeCost = 1000, magUpgradeCost = 5000, elementalUpgradeCost = 1000,
	damageUpgrade = 100, magUpgrade = 1, spreadingWeapon = true,
	proj = preload("res://Instanceables/Guns/Projectile/rocket.tscn"),
	instance = preload("res://Instanceables/Guns/rocketlauncher.tscn")
}
const grenadelauncher = {
	name = "Grenade Launcher", ammoLimited = true, gunType = 2,
	damage = 100.0, crit = 1.0, 
	magsize = 6, ammoMax = 18, reloadMult = 1.0,
	flinch = 0.5, adsOffset = 0.0,
	adsZoom = 50.0, scope = true,
	ammoCost = 40.0, upgradeCost = 1000, magUpgradeCost = 2000, elementalUpgradeCost = 1000,
	damageUpgrade = 70, magUpgrade = 1, spreadingWeapon = true,
	proj = preload("res://Instanceables/Guns/Projectile/grenade.tscn"),
	instance = preload("res://Instanceables/Guns/grenadelauncher.tscn")
}

const fireAOEPreload = preload("res://Instanceables/Guns/Projectile/FireAOE.tscn")
const iceAOEPreload = preload("res://Instanceables/Guns/Projectile/IceAOE.tscn")
const enemyRagdollPreload = preload("res://Assets/Models/Mobs/enemyragdoll.tscn")

const firemat = preload("res://Assets/Models/Materials/Fade Shaders/FireFadeShader.tres")
const icemat = preload("res://Assets/Models/Materials/Fade Shaders/IceFadeShader.tres")
const explmat = preload("res://Assets/Models/Materials/Fade Shaders/ExplodeFadeShader.tres")
const normalmat = preload("res://Assets/Models/Materials/Fade Shaders/NormalFadeShader.tres")

var paused : bool = false
var horizontalSensitivity = 0.8
var verticalSensitivity = 0.8
var highScore : int = 0
var score : int = 0
var kills : int = 0
var weapons = [GunType.RIFLE,GunType.REVOLVER,GunType.ROCKETLAUNCHER]

func _ready():
	if FileAccess.file_exists(Utils.SAVE_PATH):
		Utils.loadGame()

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
	score = 0
	kills = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func StartUI():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func playerReady():
	var player = $"../World/Player"
	player.setSens(horizontalSensitivity,verticalSensitivity)
	player.setHealth(2000.0)
	
	if weapons[0] == GunType.RIFLE:
		var riflegun = rifle.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(riflegun)
	elif weapons[0] == GunType.SNIPER:
		var snipergun = sniper.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(snipergun)
	elif weapons[0] == GunType.SHOTGUN:
		var shotgungun = shotgun.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(shotgungun)
	
	if weapons[1] == GunType.PISTOL:
		var pistolgun = pistol.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2"\
			.add_child(pistolgun)
	elif weapons[1] == GunType.REVOLVER:
		var revolvergun = revolver.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2"\
			.add_child(revolvergun)
	elif weapons[1] == GunType.SMG:
		var smggun = smg.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2"\
			.add_child(smggun)
	
	if weapons[2] == GunType.ROCKETLAUNCHER:
		var rocketgun = rocketlauncher.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon3"\
			.add_child(rocketgun)
	elif weapons[2] == GunType.GRENADELAUNCHER:
		var grenadegun = grenadelauncher.instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon3"\
			.add_child(grenadegun)
	
	player.setGuns(weapons)
	$"../World/GUI".setWeapons(weapons)

func decipherWeaponNumber(weapon):
	match weapon:
		GunType.NONE:
			return 0
		GunType.RIFLE:
			return 1
		GunType.SNIPER:
			return 2
		GunType.SHOTGUN:
			return 3
		GunType.PISTOL:
			return 0
		GunType.REVOLVER:
			return 1
		GunType.SMG:
			return 2
		GunType.ROCKETLAUNCHER:
			return 1
		GunType.GRENADELAUNCHER:
			return 2
		_:
			return 0

func choose(pri,sec,hea):
	match pri:
		0:
			weapons[0] = GunType.NONE
		1:
			weapons[0] = GunType.RIFLE
		2:
			weapons[0] = GunType.SNIPER
		3:
			weapons[0] = GunType.SHOTGUN
	
	match sec:
		0:
			weapons[1] = GunType.PISTOL
		1:
			weapons[1] = GunType.REVOLVER
		2:
			weapons[1] = GunType.SMG
	
	match hea:
		0:
			weapons[2] = GunType.NONE
		1:
			weapons[2] = GunType.ROCKETLAUNCHER
		2:
			weapons[2] = GunType.GRENADELAUNCHER

func setSensitivity(h,v):
	horizontalSensitivity = h
	verticalSensitivity = v
	Utils.saveGame()

func increaseScore(n):
	score += n
func getScore():
	return score

func setHighScore(n):
	highScore = n
func getHighScore():
	return highScore

func killEnemy(t):
	match t:
		0:#regular
			increaseScore(enemyStats.partCount)
			kills += 1
func getKills():
	return kills

func GameOver():
	if score > highScore:
		highScore = score
	$"../World/GUI".gameOver()
	if !paused:
		pause()
	Utils.saveGame()

func equip(hea,pri,dam,mag,elem):
	$"../World/GUI".equip(hea,pri,dam,mag,elem)

func pauseCheck():
	return paused
