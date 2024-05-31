extends Node2D

func _on_back_button_pressed():
	Utils.returnToMainMenu()

func _on_start_button_pressed():
	Utils.loadLevel(0)
