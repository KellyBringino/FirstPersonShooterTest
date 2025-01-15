extends Control

var progress = []
var levelstr = ""
var fading : bool = false
@onready var bar = $"CanvasLayer/Main Container/Content Container/Control/MainBarContainer/VBoxContainer/Bar Container/Progress Bar"
@onready var percent = $"CanvasLayer/Main Container/Content Container/Control/MainBarContainer/VBoxContainer/Percent Container/Percent Label"

func _ready():
	ResourceLoader.load_threaded_request(Utils.getcurrentlevel())

func _process(_delta):
	progress = []
	ResourceLoader.load_threaded_get_status(Utils.getcurrentlevel(), progress)
	if !fading:
		bar.value = progress[0] * 100
		percent.text = str((int(progress[0] * 10000) - ((int(progress[0]) * 10000) % 100)) * .01)  + "%"
	else:
		bar.value = 100.0
		percent.text = "100%"
	
	if progress[0] == 1:
		fading = true
		var packed_scene = ResourceLoader.load_threaded_get(Utils.getcurrentlevel())
		FadeCanvas.transition()
		await FadeCanvas.on_transition_finished
		get_tree().change_scene_to_packed(packed_scene)
		Game.StartLevel()
		Game.resume()
