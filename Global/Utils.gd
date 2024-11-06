extends Node

const SAVE_PATH = "res://Save/savegame.bin"

const levels = [
	"res://Levels/testing_level.tscn",
	"res://Levels/flatbush.tscn"
]
const levelNames = [
	"Testing",
	"Flatbush"
]
var levelIcons = [
	load("res://Assets/Sprites/UI/null.svg"),
	load("res://Assets/Sprites/Gun Icons/pistol_icon.png")
]

var currentLevel = 0

func saveGame():
	print("Saving")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var p = Game.decipherWeaponNumber(Game.weapons[0])
	var s = Game.decipherWeaponNumber(Game.weapons[1])
	var h = Game.decipherWeaponNumber(Game.weapons[2])
	var data: Dictionary = {
		"highscore": Game.highScore,
		"hsens": Game.horizontalSensitivity,
		"vsens": Game.verticalSensitivity,
		"primary": p,
		"secondary": s,
		"heavy": h
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	print("Saved")

func loadGame():
	print("Loading")
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				if typeof(current_line["highscore"]) == TYPE_FLOAT:
					Game.highScore = current_line["highscore"]
				if typeof(current_line["hsens"]) == TYPE_FLOAT:
					Game.horizontalSensitivity = current_line["hsens"]
				if  typeof(current_line["vsens"]) == TYPE_FLOAT:
					Game.verticalSensitivity = current_line["vsens"]
				if typeof(current_line["primary"]) == TYPE_FLOAT:
					Game.weapons[0] = Game.decipherWeaponType(int(current_line["primary"]),0)
				if typeof(current_line["secondary"]) == TYPE_FLOAT:
					Game.weapons[1] = Game.decipherWeaponType(int(current_line["secondary"]),1)
				if typeof(current_line["heavy"]) == TYPE_FLOAT:
					Game.weapons[2] = Game.decipherWeaponType(int(current_line["heavy"]),2)
	print("Loaded")

func quitGame():
	get_tree().quit()

func returnToMainMenu():
	Game.resume()
	loadGame()
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
	saveGame()
	currentLevel = 2 + number
	get_tree().change_scene_to_file(levels[number])
	Game.StartLevel()
	loadGame()

func retryLevel():
	get_tree().change_scene_to_file(levels[currentLevel - 2])
	Game.StartLevel()
	Game.resume()
	loadGame()
