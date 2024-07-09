extends Node

enum GunType {NONE, RIFLE, SNIPER, PISTOL, REVOLVER, ROCKETLAUNCHER}


const pistolInstance = preload("res://Guns/pistol.tscn")
const rifleInstance = preload("res://Guns/rifle.tscn")
const sniperInstance = preload("res://Guns/sniper.tscn")
const revolverInstance = preload("res://Guns/revolver.tscn")
const rocketlauncherInstance = preload("res://Guns/rocketlauncher.tscn")

const enemyHealth = 2000.0
const playerHealth = 2000.0

const rifleDamage = 300.0
const sniperDamage = 1000.0
const pistolDamage = 150.0
const revolverDamage = 300.0
const rocketlauncherDamage = 300.0

var paused : bool = false
var horizontalSensitivity = 0.5
var verticalSensitivity = 0.5
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
	player.setSens(0.8,0.8)
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
