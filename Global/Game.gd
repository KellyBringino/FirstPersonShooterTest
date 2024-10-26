extends Node

enum GunType {
	NONE, 
	RIFLE, SNIPER, SHOTGUN, 
	PISTOL, REVOLVER, SMG, 
	ROCKETLAUNCHER, GRENADELAUNCHER
}

const weaponMap = {
	GunType.NONE: noOne,
	GunType.RIFLE: rifle,
	GunType.SNIPER: sniper,
	GunType.SHOTGUN: shotgun,
	GunType.PISTOL: pistol,
	GunType.REVOLVER: revolver,
	GunType.SMG: smg,
	GunType.ROCKETLAUNCHER: rocketlauncher,
	GunType.GRENADELAUNCHER: grenadelauncher
}

const primaryWeaponMap = {
	GunType.NONE: noOne,
	GunType.RIFLE: rifle,
	GunType.SNIPER: sniper,
	GunType.SHOTGUN: shotgun
}
const secondaryWeaponMap = {
	GunType.PISTOL: pistol,
	GunType.REVOLVER: revolver,
	GunType.SMG: smg,
}
const heavyWeaponMap = {
	GunType.NONE: noOne,
	GunType.ROCKETLAUNCHER: rocketlauncher,
	GunType.GRENADELAUNCHER: grenadelauncher
}

const enemyStats = {
	health = 2000.0,
	damage = 200.0,
	bullet_speed = 4.0,
	levelHealth = 200,
	partCount = 20
}
const enemyMeleeStats = {
	health = 1500.0,
	damage = 200.0,
	bullet_speed = 4.0,
	levelHealth = 150,
	partCount = 25
}
const playerStats = {
	health = 2000.0,
	healthCost = 0.1
}

#no weapon stats
const noOne = {
	name = "None", ammoLimited = false, gunType = 1,
	damage = 0.0, crit = 0.0, 
	magsize = 0, ammoMax = 0, reloadMult = 1.0,
	flinch = 0.0, adsOffset = 0.0,
	adsZoom = 0.0, scope = false,
	ammoCost = 0.0, upgradeCost = 0, magUpgradeCost = 0, elementalUpgradeCost = 0,
	damageUpgrade = 0, magUpgrade = 0, spreadingWeapon = true,
	iconpath = "res://Assets/Sprites/UI/null.svg"
}

#primary stats
const rifle = {
	name = "Rifle", ammoLimited = true, gunType = 1,
	damage = 770.0, crit = 1.3, 
	magsize = 40, ammoMax = 240, reloadMult = 1.0,
	flinch = 0.2, adsOffset = -0.5,
	adsZoom = 50.0, scope = false,
	ammoCost = 1.0, upgradeCost = 600, magUpgradeCost = 400, elementalUpgradeCost = 1000,
	damageUpgrade = 1540, magUpgrade = 20, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/rifle.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/rifle_icon.png"
}
const sniper = {
	name = "Sniper Rifle", ammoLimited = true, gunType = 1,
	damage = 2500.0, crit = 2.0, 
	magsize = 5, ammoMax = 25, reloadMult = 1.0,
	flinch = 1.0, adsOffset = 0.0,
	adsZoom = 20.0, scope = true,
	ammoCost = 20.0, upgradeCost = 600, magUpgradeCost = 800, elementalUpgradeCost = 1000,
	damageUpgrade = 3500, magUpgrade = 2, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/sniper.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/sniper_icon.png"
}
const shotgun = {
	name = "Shotgun", ammoLimited = true, gunType = 1,
	damage = 650.0, crit = 1.3, 
	magsize = 5, ammoMax = 50, reloadMult = 1.0,
	pellets = 60, rings = 10,
	flinch = 1.0, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 20.0, upgradeCost = 600, magUpgradeCost = 800, elementalUpgradeCost = 1000,
	damageUpgrade = 1300, magUpgrade = 2, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/shotgun.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/shotgun_icon.png"
}
#secondary stats
const pistol = {
	name = "Pistol", ammoLimited = false, gunType = 0,
	damage = 445.0, crit = 1.5, 
	magsize = 10, reloadMult = 1.0,
	flinch = 0.2, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 0, upgradeCost = 1, magUpgradeCost = 1, elementalUpgradeCost = 1,
	damageUpgrade = 890, magUpgrade = 3, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/pistol.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/pistol_icon.png"
}
const revolver = {
	name = "Revolver", ammoLimited = false, gunType = 0,
	damage = 1177.0, crit = 1.7, 
	magsize = 6, reloadMult = 1.3,
	flinch = 0.8, adsOffset = 0.0,
	adsZoom = 50.0, scope = false,
	ammoCost = 0, upgradeCost = 400, magUpgradeCost = 600, elementalUpgradeCost = 1000,
	damageUpgrade = 2354, magUpgrade = 2, spreadingWeapon = false,
	instance = preload("res://Instanceables/Guns/revolver.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/revolver_icon.png"
}
const smg = {
	name = "SMG", ammoLimited = false, gunType = 0,
	damage = 200.0, crit = 1.3, 
	magsize = 20, reloadMult = 1.0,
	flinch = 0.4, adsOffset = 0.0,
	adsZoom = 60.0, scope = false,
	ammoCost = 0, upgradeCost = 1, magUpgradeCost = 1, elementalUpgradeCost = 1,
	damageUpgrade = 400, magUpgrade = 5, spreadingWeapon = true,
	instance = preload("res://Instanceables/Guns/smg.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/smg_icon.png"
}
#heavy stats
const rocketlauncher = {
	name = "Rocket Launcher", ammoLimited = true, gunType = 2,
	damage = 170.0, crit = 1.0, 
	magsize = 1, ammoMax = 7, reloadMult = 1.0,
	flinch = 0.0, adsOffset = 0.0,
	adsZoom = 50.0, scope = true,
	ammoCost = 40.0, upgradeCost = 1000, magUpgradeCost = 5000, elementalUpgradeCost = 1000,
	damageUpgrade = 340, magUpgrade = 1, spreadingWeapon = true,
	proj = preload("res://Instanceables/Guns/Projectile/rocket.tscn"),
	instance = preload("res://Instanceables/Guns/rocketlauncher.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/rocketlauncher_icon.png"
}
const grenadelauncher = {
	name = "Grenade Launcher", ammoLimited = true, gunType = 2,
	damage = 100.0, crit = 1.0, 
	magsize = 6, ammoMax = 18, reloadMult = 1.0,
	flinch = 0.5, adsOffset = 0.0,
	adsZoom = 50.0, scope = true,
	ammoCost = 40.0, upgradeCost = 1000, magUpgradeCost = 2000, elementalUpgradeCost = 1000,
	damageUpgrade = 200, magUpgrade = 1, spreadingWeapon = true,
	proj = preload("res://Instanceables/Guns/Projectile/grenade.tscn"),
	instance = preload("res://Instanceables/Guns/grenadelauncher.tscn"),
	iconpath = "res://Assets/Sprites/Gun Icons/grenadelauncher_icon.png"
}

const fireAOEPreload = preload("res://Instanceables/Guns/Projectile/FireAOE.tscn")
const iceAOEPreload = preload("res://Instanceables/Guns/Projectile/IceAOE.tscn")
const enemyRagdollPreload = preload("res://Assets/Models/Mobs/enemyragdoll.tscn")
const enemyBasicPreload = preload("res://Instanceables/Enemies/enemy_basic.tscn")
const enemyMeleePreload = preload("res://Instanceables/Enemies/enemy_melee.tscn")

const firemat = preload("res://Assets/Models/Materials/Fade Shaders/FireFadeShader.tres")
const icemat = preload("res://Assets/Models/Materials/Fade Shaders/IceFadeShader.tres")
const explmat = preload("res://Assets/Models/Materials/Fade Shaders/ExplodeFadeShader.tres")
const normalmat = preload("res://Assets/Models/Materials/Fade Shaders/NormalFadeShader.tres")

var weaponText : Array[ImageTexture]
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
	
	var seco = weaponMap[weapons[1]].instance.instantiate()
	$"../World/Player/CameraController/GunController/Weapon2"\
		.add_child(seco)
	if weapons[0] != GunType.NONE:
		var prim = weaponMap[weapons[0]].instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1"\
			.add_child(prim)
	if weapons[2] != GunType.NONE:
		var heav = weaponMap[weapons[2]].instance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon3"\
			.add_child(heav)
	
	player.setGuns(weapons)
	$"../World/GUI".setWeapons(weapons)

func setWeaponIcons(object):
	var p = load(weaponMap[weapons[0]].iconpath).get_image()
	var s = load(weaponMap[weapons[1]].iconpath).get_image()
	var h = load(weaponMap[weapons[2]].iconpath).get_image()
	
	print(type_string(typeof(p)))
	object.setup(
		ImageTexture.create_from_image(p),
		ImageTexture.create_from_image(s),
		ImageTexture.create_from_image(h)
		)

func setupLevelSelectIcons(object):
	var priLabels = []
	var priIcons = []
	var secLabels = []
	var secIcons = []
	var heaLabels = []
	var heaIcons = []
	for g in primaryWeaponMap:
		priLabels.append(primaryWeaponMap[g].name)
		priIcons.append(load(primaryWeaponMap[g].iconpath))
	for g in secondaryWeaponMap:
		secLabels.append(secondaryWeaponMap[g].name)
		secIcons.append(load(secondaryWeaponMap[g].iconpath))
	for g in heavyWeaponMap:
		heaLabels.append(heavyWeaponMap[g].name)
		heaIcons.append(load(heavyWeaponMap[g].iconpath))
	var values = {
		mapMax = len(Utils.levels),
		priMax = len(primaryWeaponMap),
		secMax = len(secondaryWeaponMap),
		heaMax = len(heavyWeaponMap),
		mapLabels = Utils.levelNames,
		priLabels = priLabels,
		secLabels = secLabels,
		heaLabels = heaLabels,
		mapIcons = Utils.levelIcons,
		priIcons = priIcons,
		secIcons = secIcons,
		heaIcons = heaIcons
	}
	object.setup(values)

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
