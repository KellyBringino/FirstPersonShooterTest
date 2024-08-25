extends Node2D

@onready var healthbar = $CanvasLayer/InGameGUI/HealthBarContainer/HealthBarController/HealthBar
@onready var ammobar = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoBar
@onready var ammocounter = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoCounter

@onready var main = $CanvasLayer/PauseMenu/MenuItemsContainer
@onready var options = $CanvasLayer/PauseMenu/OptionsItemsContainer
@onready var hsensbar = $CanvasLayer/PauseMenu/OptionsItemsContainer/VBoxContainer/OptionsListContainer/ScrollContainer/OptionsVBox/HSensContainer/HBoxContainer/HSliderContainer/HSensSlider
@onready var vsensbar = $CanvasLayer/PauseMenu/OptionsItemsContainer/VBoxContainer/OptionsListContainer/ScrollContainer/OptionsVBox/VSensContainer/HBoxContainer/VSliderContainer/VSensSlider

var weapons
var holdingPri : bool = true
var holdingHea : bool = false
var hsens : float = 6.0
var vsens : float = 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	unpause()
	healthbar.max_value = $"../Player".maxHealth
	healthbar.value = $"../Player".health

func _process(_delta):
	healthbar.value = $"../Player".health
	ammobar.max_value = $"../Player".heldGun.MAG_MAX
	ammobar.value = $"../Player".heldGun.mag
	ammocounter.text = "ammo:\n" + str($"../Player".heldGun.mag)

func pause():
	$CanvasLayer/PauseMenu.show()
	switchTo(0)
func unpause():
	$CanvasLayer/PauseMenu.hide()
func switchTo(page):
	match page:
		0:
			options.hide()
			main.show()
		1:
			main.hide()
			options.show()
			hsensbar.value = int((Game.horizontalSensitivity - 0.2) * 10)
			vsensbar.value = int((Game.verticalSensitivity - 0.2) * 10)

func pointgun(point):
	var cam = get_tree().root.get_camera_3d()
	if !cam.is_position_behind(point):
		var pos = cam.unproject_position(point)
		$CanvasLayer/InGameGUI/Hitmark.position = pos
	else:
		$CanvasLayer/InGameGUI/Hitmark.position = $CanvasLayer/InGameGUI/CrosshairCenterContainer.position
func dontpointgun():
	$CanvasLayer/InGameGUI/Hitmark.position = $CanvasLayer/InGameGUI/CrosshairCenterContainer.position

func setWeapons(w):
	weapons = w
	var pri = 0
	var sec = 0
	var hea = 0
	if weapons[0] == Game.GunType.RIFLE:
		pri = 1
	elif weapons[0] == Game.GunType.SNIPER:
		pri = 2
	if weapons[1] == Game.GunType.PISTOL:
		sec = 1
	elif weapons[1] == Game.GunType.REVOLVER:
		sec = 2
	if weapons[2] == Game.GunType.ROCKETLAUNCHER:
		hea = 1
	$CanvasLayer/InGameGUI/AmmoContainer/selection_wheel.setWeapons(pri,sec,hea)

func equip(hea,pri):
	holdingHea = hea
	holdingPri = pri
	$CanvasLayer/InGameGUI/AmmoContainer/selection_wheel.equip(hea,pri)

func _on_resume_button_pressed():
	Game.resume()
func _on_main_menu_button_pressed():
	Utils.returnToMainMenu()
func _on_level_select_button_pressed():
	Utils.levelSelect()
func _on_options_button_pressed():
	switchTo(1)

func _on_options_back_button_pressed():
	_on_options_save_button_pressed()
	switchTo(0)
func _on_options_save_button_pressed():
	Game.horizontalSensitivity = 0.2 + (hsens/10)
	Game.verticalSensitivity = 0.2 + (vsens/10)

func _on_h_sens_slider_drag_ended(value_changed):
	hsens = hsensbar.value
func _on_v_sens_slider_drag_ended(value_changed):
	vsens = vsensbar.value
