extends Node

var paused : bool = false
var horizontalSensitivity = 0.5
var verticalSensitivity = 0.5

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	paused = !paused
	if paused:
		StartUI()
	else:
		StartLevel()

func StartLevel():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func StartUI():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func playerReady():
	$"../World/Player".setSens(0.8,0.8)

func pauseCheck():
	return paused
