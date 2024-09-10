extends Node

const SAVE_PATH = "res://Save/savegame.bin"

const levels = [
	"res://Levels/testing_level.tscn",
	"res://Levels/rooms.tscn"
]

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
	loadGame()
