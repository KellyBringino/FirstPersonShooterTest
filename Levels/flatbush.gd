extends Level_Base

var currentItems = {"IceLamp":false}
var lamps = []
var iceLamp
var currentblueLamp = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func eventTrigger(eventName:String, eventNumber:int):
	match eventName:
		"Lamp":
			if eventNumber == currentblueLamp:
				lamps[currentblueLamp].turnNormal()
				currentblueLamp = rng.randi_range(0,len(lamps)-1)
				lamps[currentblueLamp].turnBlue()
		"IceLamp":
			if eventNumber == 0:
				currentItems[eventName] = true
			elif eventNumber == 1:
				currentItems[eventName] = false
func eventRegister(eventName:String, object):
	match eventName:
		"Lamp":
			lamps.append(object)
			object.setup(len(lamps) - 1)
			if len(lamps) - 1 == currentblueLamp:
				object.turnBlue()
			super.eventRegister(eventName + " " + str(len(lamps) - 1),object)
		"IceLamp":
			iceLamp = object
			super.eventRegister(eventName,object)
