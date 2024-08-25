extends Node

enum GunType {NONE, RIFLE, SNIPER, PISTOL, REVOLVER, ROCKETLAUNCHER}


const pistolInstance = preload("res://Guns/pistol.tscn")
const rifleInstance = preload("res://Guns/rifle.tscn")
const sniperInstance = preload("res://Guns/sniper.tscn")
const revolverInstance = preload("res://Guns/revolver.tscn")
const rocketlauncherInstance = preload("res://Guns/rocketlauncher.tscn")

const rocketInstance = preload("res://Guns/Projectile/rocket.tscn")

const enemyHealth = 2000.0
const playerHealth = 2000.0


const rifle = {name = "rifle", damage = 300.0, crit = 1.3, magsize = 40, flinch = 0.4}
const sniper = {name = "sniper", damage = 1000.0, crit = 2.0, magsize = 3, flinch = 1.0}

const pistol = {name = "pistol", damage = 300.0, crit = 1.5, magsize = 10, flinch = 0.4}
const revolver = {name = "revolver", damage = 500.0, crit = 1.5, magsize = 6, flinch = 0.8}

const rocketlauncher = {name = "rocketlauncher", damage = 300.0, crit = 1.0, magsize = 1, flinch = 0.0, proj = rocketInstance}


var paused : bool = false
var horizontalSensitivity = 0.8
var verticalSensitivity = 0.8
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
		var rifle = rifleInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1".add_child(rifle)
	elif weapons[0] == GunType.SNIPER:
		var sniper = sniperInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon1".add_child(sniper)
	
	if weapons[1] == GunType.PISTOL:
		var pistol = pistolInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2".add_child(pistol)
	elif weapons[1] == GunType.REVOLVER:
		var revolver = revolverInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon2".add_child(revolver)
	
	if weapons[2] == GunType.ROCKETLAUNCHER:
		var rocket = rocketlauncherInstance.instantiate()
		$"../World/Player/CameraController/GunController/Weapon3".add_child(rocket)
	
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
