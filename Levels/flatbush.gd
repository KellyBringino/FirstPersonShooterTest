extends Level_Base

const IceLampPreload = preload("res://Instanceables/Props/IceSpiritLamp.tscn")

@onready var iceLampSpawns = $IceSpiritSpawns.get_children()

var currentItems = {
	"IceLamp":false,
	"FreedIceSpirits":0
}
var lamps = []
var currentblueLamp = 0

# 0 -> Locate Ice Spirit Containment: find and pick up lamp
# 1 -> Ignore Posted Signage: place lamp in _
# 2 -> Break Containment: activate _ (destroys lamp)
# 3 -> Free Lesser Spirits: find and shoot _ blue lamps 
# 4 -> Call in a Cold Favor: kill _ enemies near ice lake (destroys lake)
var IceQuestStage = 0

# 0 -> Locate Brazier: find and pick up the four pieces of the big stone bowl
# 1 -> With a Thud: place stone pieces in front of curtain
# 2 -> From Afar: shoot fire shaped "crowd memebers" (spawns enemy infested with spirits)
# 3 -> Into the Cauldron: kill spirit infested enemy near stone bowl
var FireQuestStage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	enemyCount += 1
	
	#Place Ice Spirit Lantern
	var ice = IceLampPreload.instantiate()
	$Pickups.add_child(ice)
	ice.transform = iceLampSpawns[rng.randi_range(0,len(iceLampSpawns)-1)].transform
	#Deactivate Ice Bench
	$"Interactables/Ice Bench".lock()
	$"Interactables/Ice Bench".setLockPhrase("Spirits of Ice Need Your Help First")
	
	#Deactivate Fire Bench
	$"Interactables/Fire Bench".lock()
	$"Interactables/Fire Bench".setLockPhrase("Spirits of Fire Need Your Help First")
	super._ready()

func eventTrigger(eventName:String, eventNumber:int):
	match eventName:
		"IceLamp":
			if eventNumber == 0:
				if IceQuestStage == 0:
					IceQuestStage = 1
				currentItems[eventName] = true
			elif eventNumber == 1:
				if IceQuestStage == 1:
					IceQuestStage = 2
				currentItems[eventName] = false
		"Lamp":
			if eventNumber == currentblueLamp:
				lamps[currentblueLamp].turnNormal()
				currentItems["FreedIceSpirits"] += 1
				currentblueLamp = rng.randi_range(0,len(lamps)-1)
				lamps[currentblueLamp].turnBlue()
func eventRegister(eventName:String, object):
	match eventName:
		"IceLamp":
			super.eventRegister(eventName,object)
		"Lamp":
			lamps.append(object)
			object.setup(len(lamps) - 1)
			super.eventRegister(eventName + " " + str(len(lamps) - 1),object)
