extends Node2D

func _on_quit_button_pressed():
	Utils.quitGame()

func _on_start_button_pressed():
	Utils.levelSelect()
