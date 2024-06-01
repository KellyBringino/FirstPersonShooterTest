extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	unpause()

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
