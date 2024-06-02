extends Node2D

@onready var healthbar = $CanvasLayer/InGameGUI/HealthBarContainer/HealthBarController/HealthBar
@onready var ammobar = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoBar
@onready var ammocounter = $CanvasLayer/InGameGUI/AmmoContainer/AmmoController/AmmoCounter

# Called when the node enters the scene tree for the first time.
func _ready():
	unpause()
	healthbar.max_value = $"../Player".maxHealth
	healthbar.value = $"../Player".health

func _process(delta):
	healthbar.value = $"../Player".health
	ammobar.max_value = $"../Player".heldGun.MAG_MAX
	ammobar.value = $"../Player".heldGun.mag
	ammocounter.text = "ammo:\n" + str($"../Player".heldGun.mag)

func pause():
	$CanvasLayer/PauseMenu.show()
func unpause():
	$CanvasLayer/PauseMenu.hide()

func _on_resume_button_pressed():
	Game.resume()

func _on_main_menu_button_pressed():
	Utils.returnToMainMenu()

func _on_level_select_button_pressed():
	Utils.levelSelect()
