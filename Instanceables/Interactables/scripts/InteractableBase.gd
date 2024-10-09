class_name InteractableBase
extends Area3D

@onready var player = get_node("/root/World/Player")
@onready var workbenchSound = $WorkbenchSound
@onready var rejectSound = $RejectSound

@export var type : int
var phrase = "This has no function yet"
var maxPhrase = ""

func getType():#0 for health, 1 for primary ammo, 2 for heavy ammo, 3 for bench
	return type

func accessToolTip():
	var number = " (0 needed)"
	tooltip(phrase,number,false)

func activate():
	pass

func rejectHelper():
	get_node("/root/World/GUI").rejectToolTip()
	rejectSound.play()
func tooltip(str,number,accessAllowed):
	get_node("/root/World/GUI").showTooltip(str,number,accessAllowed)
func endtooltip():
	get_node("/root/World/GUI").hideTooltip()
