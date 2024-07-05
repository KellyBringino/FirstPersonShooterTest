extends Node

enum GunType {NONE, RIFLE, SNIPER, PISTOL}


const pistolInstance = preload("res://Guns/pistol.tscn")
const rifleInstance = preload("res://Guns/rifle.tscn")
const sniperInstance = preload("res://Guns/sniper.tscn")

var paused : bool = false
var horizontalSensitivity = 0.5
var verticalSensitivity = 0.5
var weapons = [GunType.SNIPER,GunType.PISTOL,GunType.NONE]

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
	
	player.setGuns(weapons)
	$"../World/GUI".setWeapons(weapons)

func equip(hea,pri):
	$"../World/GUI".equip(hea,pri)

func pauseCheck():
	return paused
