extends Node

const levels = [
	"res://Levels/testing_level.tscn"
]

func quitGame():
	get_tree().quit()

func returnToMainMenu():
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
	Game.StartUI()

func levelSelect():
	get_tree().change_scene_to_file("res://UI/LevelSelect.tscn")
	Game.StartUI()

func loadLevel(number):
	get_tree().change_scene_to_file(levels[number])
	Game.StartLevel()
