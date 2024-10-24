extends Node

const SAVE_PATH = "res://Save/savegame.bin"

const levels = [
	"res://Levels/testing_level.tscn",
	"res://Levels/rooms.tscn"
]
const levelNames = [
	"Testing",
	"Rooms"
]
var levelIcons = [
	load("res://Assets/Sprites/UI/null.svg"),
	load("res://Assets/Sprites/Gun Icons/pistol_icon.png")
]

var currentLevel = 0

func saveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		"highscore": Game.highScore,
		"hsens": Game.horizontalSensitivity,
		"vsens": Game.verticalSensitivity
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)

func loadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.highScore = current_line["highscore"]
				Game.horizontalSensitivity = current_line["hsens"]
				Game.verticalSensitivity = current_line["vsens"]

func quitGame():
	get_tree().quit()

func returnToMainMenu():
	Game.resume()
	currentLevel = 0
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
	Game.StartUI()
func switchToMainMenu():
	currentLevel = 0
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")

func levelSelect():
	Game.resume()
	currentLevel = 1
	get_tree().change_scene_to_file("res://UI/LevelSelect.tscn")
	Game.StartUI()
func switchToLevelSelect():
	currentLevel = 1
	get_tree().change_scene_to_file("res://UI/LevelSelect.tscn")

func optionsMenu():
	currentLevel = 2
	get_tree().change_scene_to_file("res://UI/OptionsMenu.tscn")

func loadLevel(number : int):
	currentLevel = 2 + number
	get_tree().change_scene_to_file(levels[number])
	Game.StartLevel()
	loadGame()

func retryLevel():
	get_tree().change_scene_to_file(levels[currentLevel - 2])
	Game.StartLevel()
	Game.resume()
	loadGame()
