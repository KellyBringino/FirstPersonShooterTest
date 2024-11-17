class_name Pickup
extends StaticBody3D

var eventStr = ""
var eventNumber = 0
var tooltipStr = ""

func pickup():
	get_node("/root/World").eventTrigger(eventStr,eventNumber)
	queue_free()

func accessTooltip():
	tooltip("Press E to pick up " + tooltipStr,"",true)

func tooltip(stri,number,accessAllowed):
	get_node("/root/World/GUI").showTooltip(stri,number,accessAllowed)
