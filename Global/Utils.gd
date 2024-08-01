extends Node

const levels = [
	"res://Levels/testing_level.tscn",
	"res://Levels/rooms.tscn"
]

func quitGame():
	get_tree().quit()

func returnToMainMenu():
	Game.resume()
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
	Game.StartUI()
func switchToMainMenu():
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")

func levelSelect():
	Game.resume()
	get_tree().change_scene_to_file("res://UI/LevelSelect.tscn")
	Game.StartUI()
func switchToLevelSelect():
	get_tree().change_scene_to_file("res://UI/LevelSelect.tscn")

func optionsMenu():
	get_tree().change_scene_to_file("res://UI/OptionsMenu.tscn")

func loadLevel(number):
	get_tree().change_scene_to_file(levels[number])
	Game.StartLevel()
