extends Level_Base

@onready var navmain = $NavMain
@onready var roomtest = $NavMain/FoxTrunk
func _ready():
	super._ready()

func _process(delta):
	#print(roomtest.isInRoom($Player.position))
	roomtest.isInRoom($Player.position)
	pass
