extends Node

enum GunType {NONE, RIFLE, SNIPER, SHOTGUN, PISTOL, REVOLVER, ROCKETLAUNCHER}

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
	name = "rifle", 
	ammoLimited = true,
	gunType = 1,
	damage = 770.0, 
	crit = 1.3, 
	magsize = 40, 
	ammoMax = 240,
	reloadMult = 1.0,
	flinch = 0.2,
	adsOffset = -0.5,
	adsZoom = 50.0,
	scope = false,
	ammoCost = 1.0,
	upgradeCost = 600,
	damageUpgrade = 500,
	magUpgradeCost = 400,
	magUpgrade = 80,
	elementalUpgradeCost = 1000,
	fastFiring = true,
	instance = preload("res://Instanceables/Guns/rifle.tscn")
}
const sniper = {
	name = "sniper", 
	ammoLimited = true,
	gunType = 1,
	damage = 2500.0, 
	crit = 2.0, 
	magsize = 3, 
	ammoMax = 18,
	reloadMult = 1.0,
	flinch = 1.0,
	adsOffset = 0.0,
	adsZoom = 20.0,
	scope = true,
	ammoCost = 20.0,
	upgradeCost = 600,
	damageUpgrade = 500,
	magUpgradeCost = 800,
	magUpgrade = 2,
	elementalUpgradeCost = 1000,
	fastFiring = false,
	instance = preload("res://Instanceables/Guns/sniper.tscn")
}
const shotgun = {
	name = "shotgun", 
	ammoLimited = true,
	gunType = 1,
	damage = 700.0, 
	crit = 1.3, 
	magsize = 5, 
	ammoMax = 50,
	pellets = 60,
	rings = 10,
	reloadMult = 1.0,
	flinch = 1.0,
	adsOffset = 0.0,
	adsZoom = 60.0,
	scope = false,
	ammoCost = 20.0,
	damageUpgrade = 520,
	magUpgrade = 2,
	upgradeCost = 600,
	magUpgradeCost = 800,
	elementalUpgradeCost = 1,#1000
	fastFiring = true,
	instance = preload("res://Instanceables/Guns/shotgun.tscn")
}
#secondary stats
const pistol = {
	name = "pistol", 
	ammoLimited = false,
	gunType = 0,
	damage = 445.0, 
	crit = 1.5, 
	magsize = 10, 
	reloadMult = 1.0,
	flinch = 0.2,
	adsOffset = 0.0,
	adsZoom = 60.0,
	scope = false,
	damageUpgrade = 255,
	magUpgrade = 3,
	upgradeCost = 1,
	magUpgradeCost = 1,
	elementalUpgradeCost = 1,
	fastFiring = false,
	instance = preload("res://Instanceables/Guns/pistol.tscn")
}
const revolver = {
	name = "revolver", 
	ammoLimited = false,
	gunType = 0,
	damage = 550.0, 
	crit = 1.7, 
	magsize = 6, 
	reloadMult = 1.3,
	flinch = 0.8,
	adsOffset = 0.0,
	adsZoom = 50.0,
	scope = false,
	upgradeCost = 400,
	damageUpgrade = 370,
	magUpgradeCost = 600,
	magUpgrade = 2,
	elementalUpgradeCost = 1000,
	fastFiring = false,
	instance = preload("res://Instanceables/Guns/revolver.tscn")
}
#heavy stats
const rocketlauncher = {
	name = "rocketlauncher", 
	ammoLimited = true,
	gunType = 2,
	damage = 400.0, 
	crit = 1.0, 
	magsize = 1, 
	ammoMax = 4,
	reloadMult = 1.0,
	flinch = 0.0,
	adsOffset = 0.0,
	adsZoom = 50.0,
	scope = true,
	ammoCost = 40.0,
	upgradeCost = 1000,
	damageUpgrade = 320,
	magUpgradeCost = 5000,
	magUpgrade = 1,
	elementalUpgradeCost = 1000,
	fastFiring = false,
	proj = preload("res://Instanceables/Guns/Projectile/rocket.tscn"),
	instance = preload("res://Instanceables/Guns/rocketlauncher.tscn")
}

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
	
	if weapons[2] == GunType.ROCKETLAUNCHER:
		var rocketgun = rocketlauncher.instance.instantiate()
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
		3:
			weapons[0] = GunType.SHOTGUN
	
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
