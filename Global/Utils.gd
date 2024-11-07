extends Node

const SAVE_PATH = "res://Save/savegame.bin"

const levels = [
	testinglevel,
	flatbush
]

const testinglevel = {
	name = "Testing",
	iconpath = "res://Assets/Sprites/UI/null.svg",
	levelpath = "res://Levels/testing_level.tscn"
}
const flatbush = {
	name = "Flatbush",
	iconpath = "res://Assets/Sprites/Gun Icons/pistol_icon.png",
	levelpath = "res://Levels/flatbush.tscn"
}

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
		"heavy": h,
		"map": Game.level
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
				#load high score
				if current_line.has("highscore") and typeof(current_line["highscore"]) == TYPE_FLOAT:
					Game.highScore = current_line["highscore"]
				else:
					Game.highScore = 0
				
				#load sensitivity
				if current_line.has("hsens") and typeof(current_line["hsens"]) == TYPE_FLOAT:
					Game.horizontalSensitivity = current_line["hsens"]
				else:
					Game.horizontalSensitivity = 0.8
				if current_line.has("vsens") and  typeof(current_line["vsens"]) == TYPE_FLOAT:
					Game.verticalSensitivity = current_line["vsens"]
				else:
					Game.verticalSensitivity = 0.8
				
				#load weapons
				if current_line.has("primary") and typeof(current_line["primary"]) == TYPE_FLOAT:
					Game.weapons[0] = Game.decipherWeaponType(int(current_line["primary"]),0)
				else:
					Game.weapons[0] = Game.decipherWeaponType(0,0)
				if current_line.has("secondary") and typeof(current_line["secondary"]) == TYPE_FLOAT:
					Game.weapons[1] = Game.decipherWeaponType(int(current_line["secondary"]),1)
				else:
					Game.weapons[1] = Game.decipherWeaponType(0,1)
				if current_line.has("heavy") and typeof(current_line["heavy"]) == TYPE_FLOAT:
					Game.weapons[2] = Game.decipherWeaponType(int(current_line["heavy"]),2)
				else:
					Game.weapons[2] = Game.decipherWeaponType(0,2)
				
				#load map
				if current_line.has("map") and typeof(current_line["map"]) == TYPE_FLOAT:
					Game.level = current_line["map"]
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
	get_tree().change_scene_to_file(levels[number].levelpath)
	Game.StartLevel()
	loadGame()

func retryLevel():
	get_tree().change_scene_to_file(levels[currentLevel - 2].levelpath)
	Game.StartLevel()
	Game.resume()
	loadGame()
