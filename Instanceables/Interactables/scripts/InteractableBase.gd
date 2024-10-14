class_name InteractableBase
extends Area3D

@onready var player = get_node("/root/World/Player")
@onready var workbenchSound = $WorkbenchSound
@onready var rejectSound = $RejectSound

var phrase = "This has no function yet"
var maxPhrase = ""

func accessToolTip():
	var number = " (0 needed)"
	tooltip(phrase,number,false)

func activate():
	pass

func rejectHelper():
	get_node("/root/World/GUI").rejectToolTip()
	rejectSound.play()
func tooltip(stri,number,accessAllowed):
	get_node("/root/World/GUI").showTooltip(stri,number,accessAllowed)
func endtooltip():
	get_node("/root/World/GUI").hideTooltip()
